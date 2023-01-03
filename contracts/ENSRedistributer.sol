// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ENSRedistributer is ERC721 {
    uint256 public maxSupply;
    uint256 public totalSupply;
    address public owner;

    struct Domain {
        string name;
        uint256 cost;
        bool isOwned;
    }

    mapping(uint256 => Domain) domains;

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    /**
        @notice add domain to supply of domains increasing max supply in the process
        @param _name the name of the domain to add
        @param _cost the cost of the domain to add
    */
    function list(string memory _name, uint256 _cost) public onlyOwner  {
        maxSupply++;
        domains[maxSupply] = Domain(_name, _cost, false);
    }

    /** 
        @notice mint domain at id provided to sender of funds in value sent with call
        @param _id id of the domain to mint
    */
    function mint(uint256 _id) public payable {
        require(_id > 0);
        require(_id <= maxSupply);
        require(domains[_id].isOwned == false);
        require(msg.value >= domains[_id].cost);

        domains[_id].isOwned = true;
        totalSupply++;

        _safeMint(msg.sender, _id);
    }

    /** 
        @notice retrieve a domain from the registry of domain names 
        @param _id id of the domain to retrieve 
        @return Domain domain struct from memory retrieved
    */
    function getDomain(uint256 _id) public view returns (Domain memory) {
        return domains[_id];
    }

    /** 
        @notice retrieve the balance of this contract
        @return uint256 balance of contract
    */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /** 
        @notice allows owner to withdraw funds stored in the contract
    */
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }

}