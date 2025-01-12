;; Historical Event Hypotheses Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var event-counter uint u0)
(define-map historical-events uint {
    title: (string-ascii 100),
    description: (string-utf8 1000),
    timestamp: uint,
    confidence: uint,
    proposer: principal,
    votes: uint
})

;; Public Functions
(define-public (propose-event (title (string-ascii 100)) (description (string-utf8 1000)) (timestamp uint) (confidence uint))
    (let
        (
            (event-id (+ (var-get event-counter) u1))
        )
        (asserts! (and (>= confidence u0) (<= confidence u100)) err-invalid-parameters)
        (map-set historical-events event-id {
            title: title,
            description: description,
            timestamp: timestamp,
            confidence: confidence,
            proposer: tx-sender,
            votes: u0
        })
        (var-set event-counter event-id)
        (ok event-id)
    )
)

(define-public (vote-on-event (event-id uint))
    (let
        (
            (event (unwrap! (map-get? historical-events event-id) err-invalid-parameters))
        )
        (map-set historical-events event-id
            (merge event {
                votes: (+ (get votes event) u1)
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-event (event-id uint))
    (map-get? historical-events event-id)
)

(define-read-only (get-event-count)
    (var-get event-counter)
)

