module sui_nft_display::nft_display {
    use sui_nft_display::version::{Version, checkVersion};
    use std::string;
    use sui::url::{Self, Url};
    use sui::event;
    use sui::package;
    use sui::display;
    use sui::table_vec;

    //CONSTANTS
    const VERSION: u64 = 1;

    // Struct definition for NFT
    public struct NFT has key {//not transferrable
        id: UID,
        name: string::String,
        description: string::String,
        image_url: Url,
        collection_id:ID,
        collection_name:string::String,
        collection_description:string::String
    }
    
    public struct AdminCap has key {
        id: UID,
    }

    // Struct for NFT Collection
    public struct NFTCollection has key, store {
        id: UID,
        name: string::String,
        description:string::String,
        nft_ids: table_vec::TableVec<ID>,
    }

    // Struct for event
    public struct NFTMinted has copy, drop {
        nft_id: ID,
        creator: address,
        collection_id:ID
    }

    public struct CollectionCreated has copy, drop {
        collection_id: ID,
        owner: address,
    }

    // For displaying NFT Image
    public struct SEKTOR13_ARCHIVES has drop {}

    fun init(otw: SEKTOR13_ARCHIVES, ctx: &mut TxContext) {
        let admin_cap = AdminCap{
            id:object::new(ctx)
        };

        let keys = vector[
            b"name".to_string(),
            b"link".to_string(),
            b"image_url".to_string(),
            b"description".to_string(),
            b"collection_id".to_string(),
            b"project_url".to_string(),
            b"creator".to_string(),
        ];

        let values = vector[
            b"{name}".to_string(),
            b"https://explorer.sui.io/object/{id}".to_string(),
            b"{image_url}".to_string(),
            b"{description}".to_string(),
            b"{collection_id}".to_string(),
            b"https://sektor13.xyz".to_string(),
            b"Sektor13".to_string()
        ];

        let publisher = package::claim(otw, ctx);
        let mut display = display::new_with_fields<NFT>(&publisher, keys, values, ctx);
        display.update_version();

        transfer::transfer(admin_cap, ctx.sender());
        transfer::public_transfer(publisher, ctx.sender());
        transfer::public_transfer(display, ctx.sender());
    }

    // Create a new NFT Collection
    #[allow(lint(self_transfer))]
    public fun create_collection(_: &AdminCap, version:&Version, name: vector<u8>,description: vector<u8>, ctx: &mut TxContext) {
        checkVersion(version, VERSION);
        let owner = tx_context::sender(ctx); // Set the owner to the transaction sender
        let nft_ids = table_vec::empty<ID>(ctx);
        let collection = NFTCollection {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            nft_ids,
            
        };
        let col_id = object::id(&collection);

        transfer::public_transfer(collection, owner);

        // Emit an event for the collection creation
        event::emit(CollectionCreated {
            collection_id: col_id,
            owner: owner,
        }); 
    }

    #[allow(lint(self_transfer))]
    public fun mint_nft(
        _: &AdminCap,
        version:&Version,
        collection: ID,
        _name: vector<u8>,
        _description: vector<u8>,
        _url: vector<u8>,
        owner: address,
        collection_name:vector<u8>,
        collection_description:vector<u8>,
        ctx: &mut TxContext,
    ) {
        checkVersion(version, VERSION);
        let nft = NFT {
            id:object::new(ctx),
            name: string::utf8(_name),
            description: string::utf8(_description),
            image_url: url::new_unsafe_from_bytes(_url),
            collection_id:collection,
            collection_name: string::utf8(collection_name),
            collection_description: string::utf8(collection_description),
        };

        let nft_id = object::id(&nft); // Access nft id before transfer
        transfer::transfer(nft, owner);

    // Emit event
        event::emit(NFTMinted {
            nft_id: nft_id,
            creator: owner,
            collection_id:collection
        });
    }

    public fun update_image_url(version:&Version, nft:&mut NFT, new_image_url: vector<u8>) {
        checkVersion(version, VERSION);
        nft.image_url = url::new_unsafe_from_bytes(new_image_url);
    }
