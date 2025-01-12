;; Galactic Simulations Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var simulation-counter uint u0)
(define-map simulations uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    parameters: (list 10 int),
    result-hash: (buff 32),
    creator: principal,
    status: (string-ascii 20)
})

;; Public Functions
(define-public (create-simulation (name (string-ascii 100)) (description (string-utf8 1000)) (parameters (list 10 int)))
    (let
        (
            (simulation-id (+ (var-get simulation-counter) u1))
        )
        (map-set simulations simulation-id {
            name: name,
            description: description,
            parameters: parameters,
            result-hash: 0x,
            creator: tx-sender,
            status: "pending"
        })
        (var-set simulation-counter simulation-id)
        (ok simulation-id)
    )
)

(define-public (update-simulation-result (simulation-id uint) (result-hash (buff 32)))
    (let
        (
            (simulation (unwrap! (map-get? simulations simulation-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator simulation)) err-not-authorized)
        (map-set simulations simulation-id
            (merge simulation {
                result-hash: result-hash,
                status: "completed"
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-simulation (simulation-id uint))
    (map-get? simulations simulation-id)
)

(define-read-only (get-simulation-count)
    (var-get simulation-counter)
)

