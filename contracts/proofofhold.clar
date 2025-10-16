;; ------------------------------------------------------------
;; ProofOfHold -- Time-Locked Loyalty Reward Contract
;; ------------------------------------------------------------
;; Encourages users to hold STX for a period and earn loyalty rewards.
;; ------------------------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NO_LOCK (err u101))
(define-constant ERR_ALREADY_LOCKED (err u102))
(define-constant ERR_LOCK_ACTIVE (err u103))
(define-constant ERR_ZERO_AMOUNT (err u104))

(define-data-var contract-owner principal tx-sender)
(define-data-var reward-rate uint u5) ;; 5% loyalty reward

;; Track user locks
(define-map locks
  { holder: principal }
  {
    amount: uint,
    start-block: uint,
    duration: uint,
    claimed: bool
  }
)

;; Event logging is not supported in Clarity. Remove or replace with comments or other mechanisms.
;; Example: Use comments to indicate the event occurrence.
;; Locked event: holder, amount, duration
;; Event logging is not supported in Clarity. Use comments to indicate event occurrences.
;; Event: Tokens unlocked - holder, amount
;; Event: Reward claimed - holder, reward

;; ------------------------------------------------------------
;; Lock STX tokens for a given duration
;; ------------------------------------------------------------
(define-public (lock-tokens (amount uint) (duration uint))
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (is-none (map-get? locks {holder: tx-sender})) ERR_ALREADY_LOCKED)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set locks {holder: tx-sender}
      {
        amount: amount,
        start-block: stacks-block-height,
        duration: duration,
        claimed: false
      })
    ;; Event: Tokens locked - holder: tx-sender, amount: amount, duration: duration
    (ok true)
  )
)

;; ------------------------------------------------------------
;; Unlock tokens (after lock period)
;; ------------------------------------------------------------
(define-public (unlock-tokens)
  (let ((lock-data (map-get? locks {holder: tx-sender})))
    (match lock-data
      data
      (let ((end-block (+ (get start-block data) (get duration data))))
        (asserts! (>= stacks-block-height end-block) ERR_LOCK_ACTIVE)
        (try! (as-contract (stx-transfer? (get amount data) (as-contract tx-sender) tx-sender)))
        (map-delete locks {holder: tx-sender})
        ;; Event: Tokens unlocked - holder: tx-sender, amount: (get amount data)
        (ok (get amount data))
      )
      ERR_NO_LOCK
    )
  )
)

;; ------------------------------------------------------------
;; Claim loyalty reward
;; ------------------------------------------------------------
(define-public (claim-reward)
  (let ((lock-data (map-get? locks {holder: tx-sender})))
    (match lock-data
      data
      (begin
        (asserts! (not (get claimed data)) ERR_NO_LOCK)
        (let ((end (+ (get start-block data) (get duration data))))
          (asserts! (>= stacks-block-height end) ERR_LOCK_ACTIVE)
          (let ((reward (/ (* (get amount data) (var-get reward-rate)) u100)))
            (map-set locks {holder: tx-sender} (merge data {claimed: true}))
            ;; Event: Reward claimed - holder: tx-sender, reward: reward
            (ok reward)
          )
        )
      )
      ERR_NO_LOCK
    )
  )
)

;; ------------------------------------------------------------
;; View lock info
;; ------------------------------------------------------------
(define-read-only (get-lock-info (user principal))
  (ok (map-get? locks {holder: user}))
)

;; ------------------------------------------------------------
;; Admin: Update reward rate
;; ------------------------------------------------------------
(define-public (set-reward-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set reward-rate new-rate)
    (ok new-rate)
  )
)
