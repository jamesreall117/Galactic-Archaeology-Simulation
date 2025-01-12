;; Stellar Data Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var star-counter uint u0)
(define-map stars uint {
    name: (string-ascii 100),
    coordinates: (tuple (x int) (y int) (z int)),
    mass: uint,
    age: uint,
    metallicity: int,
    submitter: principal
})

;; Public Functions
(define-public (submit-star-data (name (string-ascii 100)) (x int) (y int) (z int) (mass uint) (age uint) (metallicity int))
    (let
        (
            (star-id (+ (var-get star-counter) u1))
        )
        (map-set stars star-id {
            name: name,
            coordinates: {x: x, y: y, z: z},
            mass: mass,
            age: age,
            metallicity: metallicity,
            submitter: tx-sender
        })
        (var-set star-counter star-id)
        (ok star-id)
    )
)

(define-public (update-star-data (star-id uint) (name (string-ascii 100)) (x int) (y int) (z int) (mass uint) (age uint) (metallicity int))
    (let
        (
            (star (unwrap! (map-get? stars star-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get submitter star)) err-not-authorized)
        (map-set stars star-id {
            name: name,
            coordinates: {x: x, y: y, z: z},
            mass: mass,
            age: age,
            metallicity: metallicity,
            submitter: (get submitter star)
        })
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-star (star-id uint))
    (map-get? stars star-id)
)

(define-read-only (get-star-count)
    (var-get star-counter)
)

