;; Quantum Computing Power Marketplace

;; Define constants
(define-constant admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-not-exist (err u101))
(define-constant err-duplicate-listing (err u102))
(define-constant err-low-balance (err u103))
(define-constant err-low-funds (err u104))
(define-constant err-invalid-param (err u105))

;; Define data maps
(define-map quantum-assets 
  { seller: principal, asset-id: uint }
  { compute-power: uint, unit-price: uint, is-active: bool })

(define-map account-funds principal uint)

;; Define variables
(define-data-var asset-counter uint u1)
(define-data-var task-state (string-ascii 20) "queued")
(define-data-var market-multiplier uint u100)
(define-data-var cumulative-value uint u0)

;; List a quantum computing resource
(define-public (list-asset (compute-power uint) (unit-price uint))
  (if (or (is-eq compute-power u0) (is-eq unit-price u0))
      err-invalid-param
      (let
        ((asset-id (var-get asset-counter))
         (asset-value (* compute-power unit-price)))
        (map-insert quantum-assets 
          { seller: tx-sender, asset-id: asset-id }
          { compute-power: compute-power, unit-price: unit-price, is-active: true })
        (var-set asset-counter (+ asset-id u1))
        (var-set cumulative-value (+ (var-get cumulative-value) asset-value))
        (ok asset-id))))

;; Update resource availability
(define-public (update-asset-status (asset-id uint) (is-active bool))
  (let
    ((asset (unwrap! (map-get? quantum-assets { seller: tx-sender, asset-id: asset-id }) err-not-exist)))
    (map-set quantum-assets
      { seller: tx-sender, asset-id: asset-id }
      (merge asset { is-active: is-active }))
    (ok true)))

;; Book a quantum computing resource
(define-public (reserve-asset (seller principal) (asset-id uint) (quantity uint))
  (if (is-eq quantity u0)
      err-invalid-param
      (let
        ((asset (unwrap! (map-get? quantum-assets { seller: seller, asset-id: asset-id }) err-not-exist))
         (total-cost (* (get unit-price asset) quantity)))
        (asserts! (get is-active asset) err-not-exist)
        (asserts! (<= total-cost (default-to u0 (map-get? account-funds tx-sender))) err-low-balance)
        (map-set account-funds tx-sender (- (default-to u0 (map-get? account-funds tx-sender)) total-cost))
        (map-set account-funds seller (+ (default-to u0 (map-get? account-funds seller)) total-cost))
        (ok true))))

;; Deposit balance
(define-public (add-funds (amount uint))
  (if (is-eq amount u0)
      err-invalid-param
      (let
        ((user tx-sender))
        (try! (stx-transfer? amount user (as-contract tx-sender)))
        (map-set account-funds 
          user 
          (+ (default-to u0 (map-get? account-funds user)) amount))
        (ok true))))

;; Withdraw balance
(define-public (remove-funds (amount uint))
  (let
    ((user tx-sender)
     (current-balance (default-to u0 (map-get? account-funds user))))
    (asserts! (>= current-balance amount) err-low-funds)
    (try! (as-contract (stx-transfer? amount tx-sender user)))
    (map-set account-funds
      user
      (- current-balance amount))
    (ok true)))

;; Queue a job
(define-public (submit-task (seller principal) (asset-id uint) (task-data (string-ascii 1000)))
  (begin
    (try! (reserve-asset seller asset-id u1))
    (var-set task-state "queued")
    (print task-data)
    (ok true)))

;; Update job status (called by an authorized off-chain oracle)
(define-public (update-task-state (new-state (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender admin) err-admin-only)
    (var-set task-state new-state)
    (ok true)))

;; Get job status
(define-read-only (get-task-state)
  (ok (var-get task-state)))

;; Update demand factor (called periodically by an authorized off-chain oracle)
(define-public (update-market-multiplier (new-multiplier uint))
  (if (is-eq new-multiplier u0)
      err-invalid-param
      (begin
        (asserts! (is-eq tx-sender admin) err-admin-only)
        (var-set market-multiplier new-multiplier)
        (ok true))))

;; Get current price for a resource
(define-read-only (get-current-price (seller principal) (asset-id uint))
  (let
    ((asset (unwrap! (map-get? quantum-assets { seller: seller, asset-id: asset-id }) err-not-exist))
     (base-price (get unit-price asset))
     (current-demand (var-get market-multiplier)))
    (ok (* base-price (/ current-demand u100))))
)

;; Get user balance
(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? account-funds user))))

;; Get resource details for a specific provider and resource ID
(define-read-only (get-asset-details (seller principal) (asset-id uint))
  (map-get? quantum-assets { seller: seller, asset-id: asset-id }))

;; Calculate total market value (using cumulative tracking)
(define-read-only (get-total-market-value)
  (ok (var-get cumulative-value)))