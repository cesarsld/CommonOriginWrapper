pragma solidity ^0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestWrappedOrigin {
	//no way to test breedcount but logic is pretty simple
	function isValidCommonOrigin(uint256 _genes) public pure returns(bool) {
		//(uint256 _genes,) = AXIE_CORE.getAxie(_axieId);
		uint256 _originGene = (_genes >> 238) & 1;
		if (_originGene != 1)
			return false;
		uint256 _classGenes = (_genes >> 252);
		if (!isCommonClass(_classGenes))
			return false;
		//(,,uint256 _breedCount,) = AXIE_EXTRA.getExtra(_axieId);
		//if (_breedCount > 2)
		//	return false;
		return !isMystic(_genes);
	}

	function isCommonClass(uint256 _classGene) pure internal returns (bool) {
		if (_classGene == 0 || _classGene == 3 || _classGene == 4)
			return true;
		return false;
	}

	function isMystic(uint256 _genes) pure public returns (bool) {
		uint256 _part;
		uint256 _mysticSelector = 0xc0000000;
		for (uint256 i = 0; i < 6 ;i ++) {
			_part = _genes & 0xffffffff;
			if (_part & _mysticSelector == _mysticSelector)
				return true;
			_genes = _genes >> 32;
		}
		return false;
	}

	function testOriginLogic() public {
		//double mystic beast 2247
		Assert.equal(isValidCommonOrigin(4975883047140120379818980453096994491274702316904591904830302421988388505796), false, "2247 Should have been false");
		// double mystic bird 2012
		Assert.equal(isValidCommonOrigin(18545268504427207953348675590173579423853533422500024856281074112503564275972), false, "2012 Should have been false");
		//single mystic 2143
		Assert.equal(isValidCommonOrigin(26686899778937778579975610521162870997955506207650943450022047220082527111492), false, "2143 Should have been false");
		// normal axie 82169
		Assert.equal(isValidCommonOrigin(3166189940295189756259376714998220664559581900732700315595045398201401215240), false, " 82169 Should have been false");
		// xmas axie 140435
		Assert.equal(isValidCommonOrigin(4523165293865794952098248031823805681749884479533243592284759634866696357962), false, " 140435 Should have been false");
		// dusk axie 144546
		Assert.equal(isValidCommonOrigin(73274681474083123688776401609878624064713862732003192263816818830061506533386), false, "144546 Should have been false");
		// common orirgin 333
		Assert.equal(isValidCommonOrigin(1809693106329920149831849195134719741077180071152622180365483286389454018818), true, "333 Should have been true");
		// plant origin 3024
		Assert.equal(isValidCommonOrigin(21711458444626900181322888148340837462743233599010687030058887227973610768516), true, "3024 Should have been true");
		// origin aqua 3370
		Assert.equal(isValidCommonOrigin(35280843902427976618015639537133899638771478398011836203626013928767667310786), true, "3370 Should have been true");
		// bird origin 2183
		Assert.equal(isValidCommonOrigin(15831391412715648261911819537118912824982230814901125944776310240889981245570), false, "2183 Should have been false");
	}
}