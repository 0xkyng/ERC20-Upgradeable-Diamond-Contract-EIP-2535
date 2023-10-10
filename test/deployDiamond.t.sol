// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";

import "./helpers/DiamondUtils.sol";
import "../contracts/facets/ERC20Facet.sol";


contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ERC20Facet erc20Facet;

    string name = "ERC20_DIAMOND";
        string symbol = "ERC20";
        uint8 decimal = 18;
        uint256 totalSupply  = 1000000000000000000;


    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(
            address(this), 
            address(dCutFacet),
            name,
            symbol,
            decimal,
            totalSupply
            );
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Facet = new ERC20Facet();

        

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

         cut[2] = (
            FacetCut({
                facetAddress: address(erc20Facet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}

    function testName() public {
        assertEq(ERC20Facet(address(diamond)).name(), "ERC20_DIAMOND");
    }

    function testSymbol() public {
        assertEq(ERC20Facet(address(diamond)).symbol(), "ERC20");
    }

    function testDecimals() public {
        assertEq(ERC20Facet(address(diamond)).decimals(), 18);
    }

    function testTotalSupply() public {
        assertEq(ERC20Facet(address(diamond)).totalSupply(), 1000000000000000000);
    }

    function testBalanceOf() public {
        ERC20Facet(address(diamond)).mint(address(this), 1000000000000000000);
        assertEq(ERC20Facet(address(diamond)).balanceOf(address(this)), 1000000000000000000);
    }

    function testTransfer() public {
        ERC20Facet(address(diamond)).mint(address(this), 1000000000000000000);
        ERC20Facet(address(diamond)).transfer(address(0x11), 1000000000000000000);
        assertEq(ERC20Facet(address(diamond)).balanceOf(address(0x11)), 1000000000000000000);
    }

    function testAllowance() public {
        ERC20Facet(address(diamond)).mint(address(this), 1000000000000000000);
        ERC20Facet(address(diamond)).approve(address(0x11), 1000000000000000000);
        assertEq(ERC20Facet(address(diamond)).allowance(address(this), address(0x11)), 1000000000000000000);
    }

    function testApprove() public {
        ERC20Facet(address(diamond)).mint(address(this), 1000000000000000000);
        ERC20Facet(address(diamond)).approve(address(0x11), 1000000000000000000);
        assertEq(ERC20Facet(address(diamond)).allowance(address(this), address(0x11)), 1000000000000000000);
    }

    function testTransferFrom() public {
        ERC20Facet(address(diamond)).mint(address(this), 1e6);
        ERC20Facet(address(diamond)).approve(address(this), 1e5);
        ERC20Facet(address(diamond)).transferFrom(address(this), address(0x11), 1e5);
        assertEq(ERC20Facet(address(diamond)).balanceOf(address(0x11)), 1e5);
    }

   


}
