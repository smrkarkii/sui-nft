module sui_nft_display::nft_display {
    use std::string;
    use sui::url::{Self, Url};
    use sui::event;
    // use sui::tx_context::{Self, TxContext};
    // use sui::transfer;
    use sui::package;
    use sui::display;
    use sui::object;

    // Errors
    #[error]
    const ENotOwnerOfNFT: vector<u8> = b"You are not the owner of this NFT";

    // Struct definition for NFT
    public struct NFT has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
    }

    // Struct for event
    public struct NFTMinted has copy, drop {
        nft_id: ID,
        owner: address,
    }

    public struct NFTTransferred has copy, drop {
        nft_id: ID,
        to: address,
        from: address,
    }

    public entry fun mintNFT(_name: vector<u8>, _description: vector<u8>, _url: vector<u8>, ctx: &mut TxContext) {
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(_name),
            description: string::utf8(_description),
            url: url::new_unsafe_from_bytes(_url),
        };

        let sender = tx_context::sender(ctx);
        let nft_id = object::id(&nft); // Access nft id before transfer

        transfer::public_transfer(nft, sender);

        // Emit event
        event::emit(NFTMinted {
            nft_id: nft_id,
            owner: sender,
        })
    }

    public entry fun transferNFT(receiver: address, nft: NFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        // let owner = object::owner(&nft);

        // assert!(owner == sender, ENotOwnerOfNFT);

        let nft_id = object::id(&nft);
        transfer::public_transfer(nft, receiver);

        event::emit(NFTTransferred {
            nft_id: nft_id,
            to: receiver,
            from: sender,
        })
    }

    public fun getNFTName(nft: &NFT): &string::String {
        &nft.name
    }

    public fun getNFTDescription(nft: &NFT): &string::String {
        &nft.description
    }

    public fun getNFTUrl(nft: &NFT): &Url {
        &nft.url
    }

   //display
    public struct NFT_DISPLAY has drop {}

    fun init(otw: NFT_DISPLAY, ctx: &mut TxContext) {
        let keys = vector[
            b"name".to_string(),
            b"link".to_string(),
            b"image_url".to_string(),
            b"description".to_string(),
        ];

        let values = vector[
            b"{name}".to_string(),
            b"https://explorer.sui.io/object/{id}".to_string(),
            // b"https://explorer.sui.io/object/{id}".to_string(),
            // b"ipfs://{url}".to_string(),
            b"https://i.ibb.co/G5XQKqg/mithila.jpg".to_string(),
            b"{description}".to_string(),
        ];

        let publisher = package::claim(otw, ctx);
        let mut display = display::new_with_fields<NFT>(&publisher, keys, values, ctx);
        display.update_version();

        transfer::public_transfer(publisher, ctx.sender());
        transfer::public_transfer(display, ctx.sender());
    }
}
