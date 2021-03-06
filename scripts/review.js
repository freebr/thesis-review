﻿function showTotalScore() {
	if(!document.powers) return;
	var sum=0;
	var $scores=$(':text[name="scores"]');
	var $scorep=$(':text[name="scorep"]');
	var level,totalValid=true;
	var power1=document.powers.power1;
	var power2=document.powers.power2;
	var i,j,k=0;
	for(var i=0;i<power1.length;i++) {
		var sumPart=0,partValid=true;
		for(var j=0;j<power2[i].length;j++) {
			var s=$scores[k];
			if(!s.value.trim()) {
				totalValid=partValid=false;
				break;
			} else if(isNaN(s.value)) {
				sum="分值无效";
				totalValid=partValid=false;
				break;
			} else if(s.value.indexOf('.')>=0) {
				sum="第"+(i+1)+"项请输入整数";
				totalValid=partValid=false;
				break;
			}
			sumPart+=parseInt(s.value)*power2[i][j];
			k++;
		}
		sumPart*=power1[i];
		if($scorep.size()&&partValid) {
			$scorep[i].value=Math.round(sumPart);
		}
		if(totalValid) {
			sum+=sumPart;
		}
	}
	var $totalscore=$('span#totalscore');
	var $reviewleveltext=$('span#reviewleveltext');
	var $reviewlevel=$(':hidden[name="reviewlevel"]');
	if(!totalValid) {
		$reviewleveltext.html('&nbsp;');
		return;
	}
	sum=Math.round(sum);
	$totalscore.text(sum);
	if(sum<document.remarkStd[2].min) {
		$totalscore.css('color','#ff0000');
		$reviewleveltext.css('color','#ff0000');
		level=document.remarkStd[3].name;i=4;
	} else {
		$totalscore.css('color',"#000000");
		$reviewleveltext.css('color',"#000000");
		if(sum>=document.remarkStd[0].min) {
			level=document.remarkStd[0].name;i=1;
		} else if(sum>=document.remarkStd[1].min) {
			level=document.remarkStd[1].name;i=2;
		} else {
			level=document.remarkStd[2].name;i=3;
		}
	}
	$reviewleveltext.text(level);
	$reviewlevel.val(i);
	return;
}
function addScoreEventListener() {
	var elems=document.getElementsByName("scores");
	for(var i=0;i<elems.length;i++) {
		elems.item(i).oninput=showTotalScore;
		elems.item(i).onpropertychange=showTotalScore;
	}
	return;
}