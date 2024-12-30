# Qubicle Smart Contract  

**Qubicle** is a decentralized marketplace for quantum computing resources built using the Clarity smart contract language. The contract facilitates resource listing, booking, demand-based pricing, and balances management, enabling providers and users to interact seamlessly.  

---

## Features  

1. **Resource Listing**  
   Quantum resource providers can list computational resources with specifications like computational power and price per unit.  

2. **Dynamic Pricing**  
   Prices for resources adjust dynamically based on demand factors updated by an off-chain oracle.  

3. **Resource Booking**  
   Users can book computational resources by paying providers in STX tokens.  

4. **Balances Management**  
   - Users can deposit and withdraw balances.  
   - The system ensures secure and auditable transactions between users and providers.  

5. **Job Management**  
   Users can queue jobs using booked resources, and job statuses are managed by authorized updates from an oracle.  

6. **Marketplace Insights**  
   - Providers can view their listed resources.  
   - Users can query details of available resources.  
   - The system calculates the total market value of all listed resources.  

---

## Functions  

### **Public Functions**  

1. **`(list-resource (computational-power uint) (price-per-unit uint))`**  
   Providers can list a quantum computing resource. Inputs must be non-zero.  
   - **Returns:** The `resource-id` of the newly listed resource.  

2. **`(update-resource-availability (resource-id uint) (available bool))`**  
   Providers can update the availability of their listed resource.  

3. **`(book-resource (provider principal) (resource-id uint) (units uint))`**  
   Users can book a resource by specifying the provider, resource ID, and units needed.  
   - **Checks:**  
     - Resource must be available.  
     - User must have sufficient balance.  

4. **`(deposit (amount uint))`**  
   Users can deposit STX tokens into their Qubicle account.  

5. **`(withdraw (amount uint))`**  
   Users can withdraw STX tokens from their Qubicle account.  

6. **`(queue-job (provider principal) (resource-id uint) (job-data (string-ascii 1000)))`**  
   Users can queue a job after booking a resource.  

7. **`(update-job-status (new-status (string-ascii 20)))`**  
   The contract owner or authorized oracle can update the status of queued jobs.  

8. **`(update-demand-factor (new-factor uint))`**  
   The contract owner or oracle updates the demand factor, which adjusts resource prices.  

---

### **Read-Only Functions**  

1. **`(get-job-status)`**  
   Retrieves the current job status.  

2. **`(get-current-price (provider principal) (resource-id uint))`**  
   Calculates the price of a resource based on the demand factor.  

3. **`(get-balance (user principal))`**  
   Returns the STX balance of the specified user.  

4. **`(get-resource-details (provider principal) (resource-id uint))`**  
   Fetches details of a specific quantum resource.  

5. **`(get-total-market-value)`**  
   Computes the cumulative market value of all listed resources.  

---

## Data Structures  

### **Maps**  

- **`quantum-resources`**  
  Stores resource details with keys being the provider and resource ID.  

- **`user-balances`**  
  Tracks balances of users in STX tokens.  

---

## Variables  

- **`next-resource-id`**: Tracks the next available resource ID.  
- **`job-status`**: Stores the current status of queued jobs (e.g., "queued", "completed").  
- **`demand-factor`**: Determines the pricing multiplier for resources based on demand.  
- **`total-market-value`**: Maintains a running total of the market value of all resources.  

---

## Errors  

- **`err-owner-only (u100)`**: Only the contract owner can perform this action.  
- **`err-not-found (u101)`**: Resource or entry not found.  
- **`err-already-listed (u102)`**: Resource is already listed.  
- **`err-insufficient-balance (u103)`**: User does not have enough balance for the transaction.  
- **`err-insufficient-funds (u104)`**: Withdrawal amount exceeds user balance.  
- **`err-invalid-input (u105)`**: Input values are invalid (e.g., zero or negative).  

---

## Deployment  

1. Ensure you have a Clarity-compatible blockchain (e.g., Stacks).  
2. Deploy the `Qubicle` contract using your Clarity deployment tool.  
3. The deploying address becomes the contract owner.  

---

## Example Use Cases  

### **1. Listing a Resource**  
```clarity
(list-resource u500 u10)  ;; List a resource with 500 units of power priced at 10 STX/unit.
```  

### **2. Booking a Resource**  
```clarity
(book-resource 'SP1234567890ABCDEF u1 u5)  ;; Book 5 units of resource ID 1 from provider SP1234567890ABCDEF.
```  

### **3. Checking Resource Price**  
```clarity
(get-current-price 'SP1234567890ABCDEF u1)  ;; Get the adjusted price for resource ID 1.
```  

---

## Future Improvements  

1. **Off-chain Job Execution**: Integrate with quantum computing providers for seamless execution.  
2. **Enhanced Metrics**: Add analytics for resource usage trends and performance monitoring.  
3. **Multi-Tier Pricing**: Support tiered pricing based on resource configurations.  

---  

## License  

This project is open-source under the MIT License.  

---  

**Qubicle** empowers quantum computing resource providers and users to transact transparently and efficiently in a decentralized ecosystem.  