// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import './token/ERC721/ERC721.sol';
import "./utils/Strings.sol";
import "./token/ERC20/IERC20.sol";
import "./Delegable.sol";
/**
 * @title CryptoDogs
 */

contract CoinDogs is ERC721, Delegable
{
    using Strings for string;
    mapping(uint256 => string) private _uris;
    mapping(uint256 => address) private _creators;
    mapping(uint256 => uint256) private prices;
    string private _defaultUri;
    IERC20 erc20;
    constructor(address erc20_, string memory defaultUri_) ERC721("CryptoDogs","CDOG") {
        erc20=IERC20(erc20_);
        _defaultUri = defaultUri_;
    }
    function setDefaultUri(string memory _uri)public onlyOwnerOrApproved{
        _defaultUri = _uri;
    }
    function mint(
        address _to,
        uint256 _id,
        string memory _uri
    ) public onlyOwnerOrApproved {
    _mint(_to, _id);
    _uris[_id] = _uri;
    _creators[_id] = _to;
  }
  function getCreator(uint256 _id)external view returns(address){
      return _creators[_id];
  }

/*
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require( erc20.balanceOf(_msgSender()) >= prices[tokenId], "Not enough erc20 tokens");
        require(_isApprovedOrOwner(_msgSender(), tokenId) || isApproved(_msgSender()), "ERC721: transfer caller is not owner nor approved");
        erc20.transferFrom(_msgSender(),from,prices[tokenId]);
        _transfer(from, to, tokenId);
    }
    function setDogPrice(uint256 id, uint256 price )public {
        require(ownerOf(id) == _msgSender(), "Not owner of the dog");
        prices[id]=price;
    }
    
*/


    function tokenURI(uint256 id) public view override returns (string memory){
        if (_exists(id))
            return _uris[id];
        else
            return _defaultUri;
    }

}