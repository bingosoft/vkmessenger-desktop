.pragma library

var smiles = {"smiley": [
0xD83DDE04, 0xD83DDE03, 0xD83DDE00, 0xD83DDE0A, 0x263A, 0xD83DDE09, 0xD83DDE0D, 0xD83DDE18, 0xD83DDE1A, 0xD83DDE17, 0xD83DDE19, 0xD83DDE1C, 0xD83DDE1D, 0xD83DDE1B, 0xD83DDE33, 0xD83DDE01, 0xD83DDE14, 0xD83DDE0C, 0xD83DDE12, 0xD83DDE1E, 0xD83DDE23, 0xD83DDE22, 0xD83DDE02, 0xD83DDE2D, 0xD83DDE2A, 0xD83DDE25, 0xD83DDE30, 0xD83DDE05, 0xD83DDE13, 0xD83DDE29, 0xD83DDE2B, 0xD83DDE28, 0xD83DDE31, 0xD83DDE20, 0xD83DDE21, 0xD83DDE24, 0xD83DDE16, 0xD83DDE06, 0xD83DDE0B, 0xD83DDE37, 0xD83DDE0E, 0xD83DDE34, 0xD83DDE35, 0xD83DDE32, 0xD83DDE1F, 0xD83DDE26, 0xD83DDE27, 0xD83DDE08, 0xD83DDC7F, 0xD83DDE2E, 0xD83DDE2C, 0xD83DDE10, 0xD83DDE15, 0xD83DDE2F, 0xD83DDE36, 0xD83DDE07, 0xD83DDE0F, 0xD83DDE11, 0xD83DDC72, 0xD83DDC73, 0xD83DDC6E, 0xD83DDC77, 0xD83DDC82, 0xD83DDC76, 0xD83DDC66, 0xD83DDC67, 0xD83DDC68, 0xD83DDC69, 0xD83DDC74, 0xD83DDC75, 0xD83DDC71, 0xD83DDC7C, 0xD83DDC78, 0xD83DDE3A, 0xD83DDE38, 0xD83DDE3B, 0xD83DDE3D, 0xD83DDE3C, 0xD83DDE40, 0xD83DDE3F, 0xD83DDE39, 0xD83DDE3E, 0xD83DDC79, 0xD83DDC7A, 0xD83DDE48, 0xD83DDE49, 0xD83DDE4A, 0xD83DDC80, 0xD83DDC7D, 0xD83DDCA9, 0xD83DDD25, 0x2728, 0xD83CDF1F, 0xD83DDCAB, 0xD83DDCA5, 0xD83DDCA2, 0xD83DDCA6, 0xD83DDCA7, 0xD83DDCA4, 0xD83DDCA8, 0xD83DDC42, 0xD83DDC40, 0xD83DDC43, 0xD83DDC45, 0xD83DDC44, 0xD83DDC4D, 0xD83DDC4E, 0xD83DDC4C, 0xD83DDC4A, 0x270A, 0x270C, 0xD83DDC4B, 0x270B, 0xD83DDC50, 0xD83DDC46, 0xD83DDC47, 0xD83DDC49, 0xD83DDC48, 0xD83DDE4C, 0xD83DDE4F, 0x261D, 0xD83DDC4F, 0xD83DDCAA, 0xD83DDEB6, 0xD83CDFC3, 0xD83DDC83, 0xD83DDC6B, 0xD83DDC6A, 0xD83DDC6C, 0xD83DDC6D, 0xD83DDC8F, 0xD83DDC91, 0xD83DDC6F, 0xD83DDE46, 0xD83DDE45, 0xD83DDC81, 0xD83DDE4B, 0xD83DDC86, 0xD83DDC87, 0xD83DDC85, 0xD83DDC70, 0xD83DDE4E, 0xD83DDE4D, 0xD83DDE47, 0xD83CDFA9, 0xD83DDC51, 0xD83DDC52, 0xD83DDC5F, 0xD83DDC5E, 0xD83DDC61, 0xD83DDC60, 0xD83DDC62, 0xD83DDC55, 0xD83DDC54, 0xD83DDC5A, 0xD83DDC57, 0xD83CDFBD, 0xD83DDC56, 0xD83DDC58, 0xD83DDC59, 0xD83DDCBC, 0xD83DDC5C, 0xD83DDC5D, 0xD83DDC5B, 0xD83DDC53, 0xD83CDF80, 0xD83CDF02, 0xD83DDC84, 0xD83DDC9B, 0xD83DDC99, 0xD83DDC9C, 0xD83DDC9A, 0x2764, 0xD83DDC94, 0xD83DDC97, 0xD83DDC93, 0xD83DDC95, 0xD83DDC96, 0xD83DDC9E, 0xD83DDC98, 0xD83DDC8C, 0xD83DDC8B, 0xD83DDC8D, 0xD83DDC8E, 0xD83DDC64, 0xD83DDC65, 0xD83DDCAC, 0xD83DDC63, 0xD83DDCAD
]};

var sortedSmiles = [];

for (var k in smiles)
	sortedSmiles = sortedSmiles.concat(smiles[k]);

sortedSmiles = sortedSmiles.sort(function(a, b) { return a - b; });

function hasSmile(smile) {
	//console.log("has " + smile);
    var smileCode = parseInt(smile, 16);
    var l = 0;
    var r = sortedSmiles.length - 1;

	//console.log(smileCode + " => ");

    while (l != r) {
        var m = Math.floor((l + r) / 2);

		//console.log("l - " + l + ", m - " + m + ", r - " + r);
		//console.log(sortedSmiles[m]);

        if (smileCode > sortedSmiles[m])
            l = m + 1;
        else if (smileCode < sortedSmiles[m])
            r = m;
        else
            return true;
    }

	//console.log(" =>> " + sortedSmiles[l]);
    return sortedSmiles[l] == smileCode;
}

function detectSmilies(message) {
//    "<img src='http://vk.com/images/emoji/D83DDE35.png'>";
	//console.log("detect smile");
	//var smiles = "";
    var smile = "";
    var newMessage = "";
	var i = 0;
	var extra = "";
	var code = 0;

	while (i <= message.length) {
		if (smile.length > 0) {
			if (hasSmile(smile))
				//newMessage += "<img src='http://vk.com/images/emoji/" + smile.toUpperCase() + ".png'>";
				newMessage += "<img src='../images/emoji/" + smile.toUpperCase() + ".png'>";
			else {
				newMessage += message[i - 1];
			}

			if (i == message.length)
				break;
		}

		code = message.charCodeAt(i);
		i++;
		if (code >= 0xD800 && code <= 0xDBFF && i < message.length) {
			extra = message.charCodeAt(i);
			if ((extra & 0xFC00) == 0xDC00) {
				smile = code.toString(16).toUpperCase() + extra.toString(16).toUpperCase();
				i++;
				continue;
			}
		}
		smile = code.toString(16).toUpperCase();
	}

	//smiles += smile + " ";
	//console.log(smiles);
	
	return newMessage;
}


