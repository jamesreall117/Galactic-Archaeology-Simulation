;; Galactic Discovery NFT Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; NFT Definition
(define-non-fungible-token galactic-discovery uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-map token-metadata uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    image-url: (string-ascii 256),
    discovery-type: (string-ascii 20),
    timestamp: uint,
    discoverer: principal
})

;; Public Functions
(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (image-url (string-ascii 256)) (discovery-type (string-ascii 20)))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (try! (nft-mint? galactic-discovery token-id tx-sender))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            image-url: image-url,
            discovery-type: discovery-type,
            timestamp: block-height,
            discoverer: tx-sender
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? galactic-discovery token-id) err-not-token-owner)) err-not-token-owner)
        (try! (nft-transfer? galactic-discovery token-id tx-sender recipient))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get last-token-id)
)

