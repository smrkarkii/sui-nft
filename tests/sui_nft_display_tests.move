
#[test_only]
module sui_nft_display::sui_nft_display_tests{

use sui_nft_display::nft_display::{mintNFT, transferNFT, getNFTDescription, getNFTName, getNFTUrl};
// 



// const ENotImplemented: u64 = 0;

#[test]
fun test_mint_nft() {
    //dummy TxContext for testing
    let mut ctx = tx_context::dummy();

    //mimt a nft
    mintNFT(b"Test nft", b"Test description", b"https://i.ibb.co/G5XQKqg/mithila.jpg", &mut ctx);
   
//check the values of nft
    //  assert!(getNFTName(&nft) == b"Test nft".to_string(), 0);

}
}