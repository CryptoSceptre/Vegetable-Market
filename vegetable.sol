// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VegetableMarket {
    address public owner;
    uint256 public retailerCount;
    uint256 public wholesalerCount;

    enum VegetableType { Tomato, Potato, Onion, Carrot, Cucumber, Spinach, Broccoli, Cauliflower, Eggplant, BellPepper }

    struct Vegetable {
        uint256 stock;
        uint256 price; // price per kg
    }

    struct Retailer {
        address retailerAddress;
        mapping(uint8 => Vegetable) inventory;
    }

    struct Wholesaler {
        address wholesalerAddress;
        mapping(uint8 => Vegetable) supply;
    }

    mapping(address => Retailer) public retailers;
    mapping(address => Wholesaler) public wholesalers;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyRetailer() {
        require(retailers[msg.sender].retailerAddress == msg.sender, "Only registered retailers can call this function");
        _;
    }

    modifier onlyWholesaler() {
        require(wholesalers[msg.sender].wholesalerAddress == msg.sender, "Only registered wholesalers can call this function");
        _;
    }

    function registerRetailer() public {
        require(retailers[msg.sender].retailerAddress == address(0), "Retailer already registered");
    
        retailerCount++;
        Retailer storage newRetailer = retailers[msg.sender];
        newRetailer.retailerAddress = msg.sender;
        for (uint8 i = 0; i < 10; i++) {
            newRetailer.inventory[i] = Vegetable(0, 0); // Initialize all vegetable types
    }
    }

    function registerWholesaler() public {
        require(wholesalers[msg.sender].wholesalerAddress == address(0), "Wholesaler already registered");
    
        wholesalerCount++;
        wholesalers[msg.sender].wholesalerAddress = msg.sender;
        for (uint8 i = 0; i < 10; i++) {
        wholesalers[msg.sender].supply[i] = Vegetable(0, 0); // Initialize all vegetable types
    }
    }

    function setVegetableStock(uint8 vegetableType, uint256 stock) public onlyWholesaler {
        wholesalers[msg.sender].supply[vegetableType].stock = stock;
    }

    function setVegetablePrice(uint8 vegetableType, uint256 price) public onlyWholesaler {
        wholesalers[msg.sender].supply[vegetableType].price = price;
    }

    function purchaseVegetables(address wholesalerAddress, uint8 vegetableType, uint256 quantity) public onlyRetailer {
        require(retailers[msg.sender].inventory[vegetableType].stock + quantity <= wholesalers[wholesalerAddress].supply[vegetableType].stock, "Not enough stock available");
        uint256 cost = quantity * wholesalers[wholesalerAddress].supply[vegetableType].price;
        require(cost <= address(this).balance, "Contract does not have enough balance to complete the purchase.");
        retailers[msg.sender].inventory[vegetableType].stock += quantity;
        payable(wholesalerAddress).transfer(cost);
    }

    function getRetailerInventory(uint8 vegetableType) public view onlyRetailer returns (uint256 stock, uint256 price) {
        Retailer storage retailer = retailers[msg.sender];
        Vegetable storage vegetable = retailer.inventory[vegetableType];
        return (vegetable.stock, vegetable.price);
    }

    function getWholesalerSupply(uint8 vegetableType) public view onlyWholesaler returns (uint256 stock, uint256 price) {
        Wholesaler storage wholesaler = wholesalers[msg.sender];
        Vegetable storage vegetable = wholesaler.supply[vegetableType];
        return (vegetable.stock, vegetable.price);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
