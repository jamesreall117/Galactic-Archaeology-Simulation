;; Collaboration Tools Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var project-counter uint u0)
(define-map projects uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    creator: principal,
    collaborators: (list 10 principal),
    status: (string-ascii 20)
})

(define-map project-data {project-id: uint, key: (string-ascii 100)} (string-utf8 1000))

;; Public Functions
(define-public (create-project (name (string-ascii 100)) (description (string-utf8 1000)))
    (let
        (
            (project-id (+ (var-get project-counter) u1))
        )
        (map-set projects project-id {
            name: name,
            description: description,
            creator: tx-sender,
            collaborators: (list tx-sender),
            status: "active"
        })
        (var-set project-counter project-id)
        (ok project-id)
    )
)

(define-public (add-collaborator (project-id uint) (collaborator principal))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator project)) err-not-authorized)
        (asserts! (< (len (get collaborators project)) u10) err-invalid-parameters)
        (map-set projects project-id
            (merge project {
                collaborators: (unwrap! (as-max-len? (append (get collaborators project) collaborator) u10) err-invalid-parameters)
            })
        )
        (ok true)
    )
)

(define-public (add-project-data (project-id uint) (key (string-ascii 100)) (value (string-utf8 1000)))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
        )
        (asserts! (is-some (index-of (get collaborators project) tx-sender)) err-not-authorized)
        (map-set project-data {project-id: project-id, key: key} value)
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-project (project-id uint))
    (map-get? projects project-id)
)

(define-read-only (get-project-data (project-id uint) (key (string-ascii 100)))
    (map-get? project-data {project-id: project-id, key: key})
)

(define-read-only (get-project-count)
    (var-get project-counter)
)

