// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { WebLib } from "../WebLib.sol";
import { Sculpture } from "../../Sculpture.sol";
import { SculptureERC721 } from "../../SculptureERC721.sol";
import { ContractShow } from "../../ContractShow.sol";
import { LibString } from "solady/utils/LibString.sol";
import { IERC721Metadata } from "../../lib/IERC721Metadata.sol";

library MediaPage {
    using LibString for string;
    using LibString for uint256;

    function html(address show, uint256 index) public view returns (string memory) {
        Sculpture[] memory sculptures = ContractShow(show).getSculptures();
        if (index >= sculptures.length) {
            return "";
        }
        Sculpture sculpture = sculptures[index];
        string memory mimeUrl = WebLib.firstMimeUrl(sculpture);
        string memory title = sculpture.title();

        return _buildHtml(index, mimeUrl, title);
    }

    function tokenUri(address showAddress, uint256 index) public view returns (string memory) {
        ContractShow show = ContractShow(showAddress);
        Sculpture[] memory sculptures = show.getSculptures();
        if (index >= sculptures.length) {
            return "";
        }
        SculptureERC721 memory sculptureERC721 = show.getSculptureERC721(sculptures[index]);
        return IERC721Metadata(sculptureERC721.contractAddress).tokenURI(sculptureERC721.tokenId);
    }

    function _buildHtml(
        uint256 index,
        string memory mimeUrl,
        string memory title
    ) internal pure returns (string memory) {
        string memory css = "html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:transparent}"
        "body{display:block}img{width:100%;height:100%;object-fit:contain;object-position:left top;display:block}"
        "video{width:100%;height:100%;object-fit:contain;object-position:left top;display:block}"
        "body.video-fit video{max-width:100%;max-height:100%;width:auto;height:auto}"
        "iframe{border:0;width:100%;height:100%;display:block;overflow:hidden}";

        // Embed only the small data (mimeUrl, title, index) - tokenUri is fetched via /token-uri endpoint
        return
            string.concat(
                '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>',
                css,
                "</style></head><body>",
                '<script type="text/plain" id="mimeUrlData">',
                mimeUrl,
                '</script><script type="text/plain" id="titleData">',
                WebLib.escapeHtml(title),
                "</script><script>",
                _mediaScript(index),
                "</script></body></html>"
            );
    }

    function _mediaScript(uint256 index) internal pure returns (string memory) {
        return
            string.concat(
                "(function(){'use strict';"
                "var mimeUrl=document.getElementById('mimeUrlData').textContent;"
                "var title=document.getElementById('titleData').textContent;"
                "var tokenUriUrl='/token-uri/",
                index.toString(),
                "';"
                "function a(s){let r='';for(let i=0;i<s.length;i++){const c=s[i];"
                "if(c==='%'&&i+2<s.length){const h=s.slice(i+1,i+3),n=parseInt(h,16);if(!isNaN(n)){r+=String.fromCharCode(n);"
                "i+=2;continue}}r+=c==='+'?' ':c}return r}function b(s){try{const n=s.replace(/-/g,'+').replace(/_/g,'/'),"
                "d=atob(n),u=new Uint8Array(d.length);for(let i=0;i<d.length;i++)u[i]=d.charCodeAt(i);"
                "return new TextDecoder('utf-8').decode(u)}catch(e){return''}}function c(s){try{const u=new TextEncoder().encode(s);"
                "let d='';for(let i=0;i<u.length;i++)d+=String.fromCharCode(u[i]);return btoa(d)}catch(e){return''}}"
                "function d(u){if(!u)return{image:'',animation:''};let j='';"
                "if(u.startsWith('data:application/json;base64,'))j=b(u.slice(29));"
                "else if(u.startsWith('data:application/json;utf8,'))j=u.slice(27);"
                "else if(u.startsWith('data:application/json,'))j=a(u.slice(22));"
                "else return{image:'',animation:''};return e(j)}"
                "function e(s){try{const o=JSON.parse(s);return{image:o.image||o.image_url||'',animation:o.animation_url||''}}"
                "catch(x){return{image:'',animation:''}}}"
                "function f(u){if(!u.startsWith('data:text/html;base64,'))return u;let h=b(u.slice(22));"
                "const r='<style>*{margin:0!important;padding:0!important;box-sizing:border-box!important}"
                "html,body{width:100%!important;height:100%!important;background:transparent!important;"
                "overflow:hidden!important;justify-content:flex-start!important;align-items:flex-start!important}</style>';"
                "h=h.includes('<head>')?h.replace('<head>','<head>'+r):h.includes('<html>')?h.replace('<html>','<html><head>'+r+'</head>'):r+h;"
                "return'data:text/html;base64,'+c(h)}"
                "function g(s){return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\"/g,'&quot;')}"
                "function h(u,t){if(!u)return{html:'',isVideo:false};"
                "if(u.startsWith('data:video/')||u.endsWith('.mp4')||u.endsWith('.webm')||u.endsWith('.mov'))"
                'return{html:\'<video src="\'+u+\'" loop muted autoplay playsinline class="token-media" style="cursor:pointer"></video>\',isVideo:true};'
                "if(u.startsWith('data:text/html')||u.endsWith('.html')||u.endsWith('.htm'))"
                'return{html:\'<iframe src="\'+f(u)+\'" class="token-media token-iframe" sandbox="allow-scripts"></iframe>\',isVideo:false};'
                "return{html:'<img src=\"'+u+'\" alt=\"'+g(t||'')+'\" class=\"token-media\">',isVideo:false}}"
                "function i(){document.querySelectorAll('video.token-media').forEach(function(v){v.onclick=function(){v.muted=!v.muted}})}"
                "function render(tokenUri){"
                "var r={html:'',isVideo:false};"
                "if(mimeUrl)r=h(mimeUrl,title);"
                "else if(tokenUri){const{image,animation}=d(tokenUri);r=animation?h(animation,title):image?h(image,title):{html:'',isVideo:false}}"
                "if(r.isVideo)document.body.classList.add('video-fit');document.body.innerHTML=r.html;i()}"
                "if(mimeUrl){render('')}else{"
                "fetch(tokenUriUrl).then(r=>r.text()).then(render).catch(()=>render(''))}"
                "})();"
            );
    }
}
