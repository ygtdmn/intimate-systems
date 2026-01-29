// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

library Layout {
    function html(
        string memory body,
        string memory title,
        string memory description
    ) external pure returns (string memory) {
        string memory html_ = '<!DOCTYPE html><html lang="en">';
        html_ = string.concat(html_, "<head>");
        html_ = string.concat(html_, '<meta charset="UTF-8">');
        html_ = string.concat(html_, '<meta name="viewport" content="width=device-width, initial-scale=1.0">');
        html_ = string.concat(html_, "<title>", title, "</title>");
        html_ = string.concat(html_, '<meta name="description" content="', description, '">');
        html_ = string.concat(html_, '<link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMS4yNSIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48cGF0aCBkPSJNNyAxMiBMNyAyOCBMMjUgMjggTDI1IDEyIFogTTcgMTIgTDE2IDQgTDI1IDEyIEwxNiAyMiBaIE0xNiA0IEwxNiAyMiBMMTYgMjggTTE2IDIyIEw3IDI4IE0xNiAyMiBMMjUgMjgiLz48L3N2Zz4=">');

        string
            memory css = ":root{--bg:#ffffff;--fg:#111111;--font-display:system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;--font-mono:ui-monospace,'SF Mono',SFMono-Regular,Menlo,Consolas,monospace;}";
        css = string.concat(css, "*{margin:0;padding:0;box-sizing:border-box;font-weight:400;}");
        css = string.concat(
            css,
            "html{font-size:16px;background-color:var(--bg);color:var(--fg);scroll-behavior:smooth;}"
        );
        css = string.concat(
            css,
            "body{font-family:var(--font-display);line-height:1.7;-webkit-font-smoothing:antialiased;overflow-x:hidden;}"
        );
        css = string.concat(
            css,
            ".loading{position:fixed;top:0;left:0;width:100%;height:100vh;background:var(--bg);display:flex;align-items:center;justify-content:center;z-index:1000;transition:opacity 0.5s ease;}"
        );
        css = string.concat(css, ".loading.hidden{opacity:0;pointer-events:none;visibility:hidden;}");
        css = string.concat(css, "@keyframes dotPulse{0%,80%,100%{opacity:0.2}40%{opacity:1}}");
        css = string.concat(css, ".loading-text{font-size:1.5rem;color:var(--fg);font-family:var(--font-mono);letter-spacing:0.25rem;}");
        css = string.concat(css, ".loading-text span{animation:dotPulse 1.4s infinite;}");
        css = string.concat(css, ".loading-text span:nth-child(2){animation-delay:0.2s;}");
        css = string.concat(css, ".loading-text span:nth-child(3){animation-delay:0.4s;}");
        css = string.concat(css, ".gallery-flow{width:100%;max-width:1200px;margin:0 auto;position:relative;}");
        css = string.concat(
            css,
            ".intro-section{min-height:100vh;min-height:100dvh;padding:4rem 2rem;display:flex;flex-direction:column;justify-content:center;align-items:flex-start;max-width:750px;}"
        );
        css = string.concat(
            css,
            ".intro-title{font-family:var(--font-display);font-size:clamp(1.5rem,4vw,2.2rem);font-weight:400;line-height:1.2;letter-spacing:0.01em;color:var(--fg);margin:0 0 1.5rem 0;}"
        );
        css = string.concat(css, ".intro-subtitle{font-size:1rem;line-height:1.7;margin:0 0 4rem 0;}");
        css = string.concat(css, ".intro-subtitle a{color:var(--fg);text-decoration:none;}");
        css = string.concat(css, ".intro-subtitle a:hover{opacity:0.5;}");
        css = string.concat(
            css,
            ".intro-artists{font-size:1.1rem;line-height:1.7;margin:0 0 4rem 0;word-break:break-word;}"
        );
        css = string.concat(css, ".intro-artists a,.intro-artists a:visited{color:var(--fg);text-decoration:none;}");
        css = string.concat(css, ".intro-artists a:hover{opacity:0.5;}");
        css = string.concat(css, ".intro-essay{margin:0 0 1.5rem 0;}");
        css = string.concat(css, ".intro-essay a{font-size:1rem;color:var(--fg);text-decoration:none;}");
        css = string.concat(css, ".intro-essay a:hover{opacity:0.5;}");
        css = string.concat(
            css,
            ".intro-thanks{font-size:0.9rem;font-style:italic;color:var(--fg);margin:0 0 4rem 0;line-height:1.7;}"
        );
        css = string.concat(
            css,
            ".intro-thanks a,.intro-thanks a:visited{color:var(--fg);text-decoration:none;opacity:0.55;}"
        );
        css = string.concat(css, ".intro-thanks a:hover{opacity:1;}");
        css = string.concat(css, ".intro-thanks span{opacity:0.55;}");
        css = string.concat(css, ".intro-meta{font-size:0.8rem;color:var(--fg);margin:0;}");
        css = string.concat(css, ".intro-meta span{opacity:0.4;}");
        css = string.concat(
            css,
            ".intro-meta a,.intro-meta a:visited{font-family:var(--font-mono);font-size:0.75rem;color:var(--fg);text-decoration:none;margin-left:1.5rem;opacity:0.4;word-break:break-word;}"
        );
        css = string.concat(css, ".intro-meta a:hover{opacity:1;}");
        css = string.concat(
            css,
            ".about-section{min-height:100vh;display:flex;flex-direction:column;justify-content:center;padding:4rem 2rem;max-width:650px;margin:0;}"
        );
        css = string.concat(
            css,
            ".about-content{display:flex;flex-direction:column;align-items:flex-start;gap:1.5rem;}"
        );
        css = string.concat(
            css,
            ".about-text{font-family:var(--font-display);font-size:1rem;line-height:1.8;color:var(--fg);}"
        );
        css = string.concat(css, ".works-section{padding:2rem 2rem 10rem;margin-top:40vh;max-width:1000px;}");
        css = string.concat(css, ".sculpture{margin-bottom:33vh;}");
        css = string.concat(css, ".sculpture-header{margin-bottom:4rem;}");
        css = string.concat(
            css,
            ".sculpture-authors{font-size:0.9rem;color:var(--fg);opacity:0.5;margin-bottom:0.5rem;word-break:break-word;}"
        );
        css = string.concat(
            css,
            ".sculpture-title{font-size:1.5rem;font-weight:500;letter-spacing:0.05em;color:var(--fg);}"
        );
        css = string.concat(css, ".sculpture-media{margin:6rem 0;width:100%;}");
        css = string.concat(
            css,
            ".token-media{display:block;max-width:100%;max-height:80vh;min-height:70vh;width:auto;height:auto;margin:0;}"
        );
        css = string.concat(css, ".token-media + .token-media{margin-top:4rem;}");
        css = string.concat(css, "iframe.token-media{border:none;width:100%;aspect-ratio:1;}");
        css = string.concat(css, "@media (min-width:769px){iframe.token-media{min-height:70vh;max-height:80vh;}}");
        css = string.concat(css, "video.token-media{max-height:80vh;object-fit:contain;}");
        css = string.concat(
            css,
            ".sculpture-text{font-family:var(--font-display);font-size:1rem;line-height:1.8;color:var(--fg);max-width:550px;margin:0;word-break:break-word;}"
        );
        css = string.concat(css, ".sculpture-text p{margin-bottom:1.5rem;}");
        css = string.concat(
            css,
            ".sculpture-text a{color:var(--fg);text-decoration:underline;text-decoration-color:var(--fg);text-underline-offset:4px;}"
        );
        css = string.concat(css, ".sculpture-urls{margin-top:1.5rem;display:flex;flex-direction:column;gap:0.5rem;}");
        css = string.concat(
            css,
            ".external-link{display:inline-block;width:fit-content;font-size:1rem;color:var(--fg);text-overflow:ellipsis;white-space:nowrap;overflow:hidden;max-width:100%;}"
        );
        css = string.concat(
            css,
            ".url-thumbnail{display:block;max-width:100px;max-height:100px;padding:0.25rem;margin-top:1rem;}"
        );
        css = string.concat(
            css,
            ".sculpture-footer{display:flex;flex-direction:column;align-items:flex-start;gap:0.25rem;margin-top:4rem;}"
        );
        css = string.concat(
            css,
            ".sculpture-address{font-family:var(--font-mono);font-size:0.75rem;color:var(--fg);text-decoration:none;word-break:break-word;}"
        );
        css = string.concat(css, ".footer-section{padding:8rem 2rem;margin-top:10rem;}");
        css = string.concat(
            css,
            ".footer-content{max-width:1000px;margin:0;display:flex;flex-wrap:wrap;justify-content:flex-start;gap:4rem;}"
        );
        css = string.concat(
            css,
            ".project-info,.chain-info{font-size:0.875rem;color:var(--fg);opacity:0.8;word-break:break-word;}"
        );
        css = string.concat(
            css,
            ".project-info a,.chain-info a{color:var(--fg);text-decoration:underline;text-underline-offset:2px;}"
        );
        css = string.concat(css, ".project-info a:hover{opacity:0.6;}");
        css = string.concat(
            css,
            "@media (max-width:768px){.intro-section{padding:3rem 1.5rem;}.intro-title{font-size:clamp(1.8rem,8vw,2.8rem);}.intro-subtitle,.intro-artists,.intro-thanks{margin-bottom:3rem;}.sculpture-text{font-size:1rem;}.footer-content{flex-direction:column;gap:2rem;}}"
        );
        css = string.concat(
            css,
            "@media (max-width:480px){.intro-section{padding:2.5rem 1.25rem;}.intro-meta a{display:block;margin-left:0;margin-top:0.5rem;}}"
        );

        html_ = string.concat(html_, "<style>", css, "</style>");
        html_ = string.concat(html_, "</head>");
        html_ = string.concat(
            html_,
            '<body><div class="loading" id="loading"><span class="loading-text"><span>.</span><span>.</span><span>.</span></span></div>',
            body,
            _loadingScript(),
            "</body></html>"
        );
        return html_;
    }

    function _loadingScript() internal pure returns (string memory) {
        return "<script>"
            "(function(){"
            "var loading=document.getElementById('loading');"
            "var iframes=document.querySelectorAll('iframe.token-media');"
            "var total=iframes.length;"
            "var loadedCount=0;"
            "function hideLoading(){loading.classList.add('hidden');}"
            "function checkAllLoaded(){loadedCount++;if(loadedCount>=total){setTimeout(hideLoading,300);}}"
            "function waitForMedia(doc){"
            "return new Promise(function(resolve){"
            "var imgs=doc.querySelectorAll('img');"
            "var vids=doc.querySelectorAll('video');"
            "var innerIframes=doc.querySelectorAll('iframe');"
            "var mediaCount=imgs.length+vids.length+innerIframes.length;"
            "if(mediaCount===0){resolve();return;}"
            "var mediaLoaded=0;"
            "function onMediaLoad(){mediaLoaded++;if(mediaLoaded>=mediaCount)resolve();}"
            "imgs.forEach(function(img){if(img.complete)onMediaLoad();else{img.onload=onMediaLoad;img.onerror=onMediaLoad;}});"
            "vids.forEach(function(vid){if(vid.readyState>=3)onMediaLoad();else{vid.onloadeddata=onMediaLoad;vid.onerror=onMediaLoad;}});"
            "innerIframes.forEach(function(f){f.onload=onMediaLoad;});"
            "setTimeout(resolve,15000);"
            "});"
            "}"
            "if(total===0){hideLoading();return;}"
            "iframes.forEach(function(iframe){"
            "iframe.addEventListener('load',function(){"
            "try{var doc=iframe.contentDocument||iframe.contentWindow.document;"
            "waitForMedia(doc).then(checkAllLoaded);}catch(e){checkAllLoaded();}"
            "});"
            "});"
            "setTimeout(hideLoading,45000);"
            "})();"
            "</script>";
    }
}
