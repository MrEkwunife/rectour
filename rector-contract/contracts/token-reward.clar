
;; token-reward
;; <add a description here>

(define-trait sip-010-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (transfer-memo (uint principal principal (buff 34)) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

(define-data-var reward-tokens uint u0)
(define-map registered-users principal uint)
(define-constant contract-owner tx-sender)

(define-private (is-authorized?)
  (is-eq tx-sender contract-owner)
)

(define-public (register-user)
  (begin
    (asserts! (is-none (map-get? registered-users tx-sender)) (err u1))
    (map-set registered-users tx-sender u0)
    (ok true)
  )
)

(define-public (earn-rewards (amount uint))
  (let 
    (
      (current-balance (default-to u0 (map-get? registered-users tx-sender)))
    )
    (begin
      (asserts! (is-some (map-get? registered-users tx-sender)) (err u2))
      (asserts! (is-authorized?) (err u3))
      (map-set registered-users tx-sender (+ current-balance amount))
      (var-set reward-tokens (+ (var-get reward-tokens) amount))
      (ok true)
    )
  )
)

(define-public (redeem-rewards (amount uint))
  (let 
    (
      (current-balance (default-to u0 (map-get? registered-users tx-sender)))
    )
    (begin
      (asserts! (is-some (map-get? registered-users tx-sender)) (err u2))
      (asserts! (>= current-balance amount) (err u4))
      (map-set registered-users tx-sender (- current-balance amount))
      (var-set reward-tokens (- (var-get reward-tokens) amount))
      (ok true)
    )
  )
)

(define-read-only (get-reward-balance (user principal))
  (ok (default-to u0 (map-get? registered-users user)))
)

(define-read-only (get-total-rewards-available)
  (ok (var-get reward-tokens))
)