const puppeteer = require('puppeteer');

// Get ARGV
const args = process.argv.slice(2);
var viewWidth = 0;
var viewheight = 0;

// Set width based on ARGV
if (args[0] === undefined) {
	viewWidth = 264;
} else {
	viewWidth = parseInt(args[0], 10);
}

// Set height based on ARGV
if (args[1] === undefined) {
	viewHeight = 176;
} else {
	viewHeight = parseInt(args[1], 10);
}

// Get HTML content from pipe
var htmlContent = '';
process.stdin.setEncoding('utf-8');

process.stdin.on('readable', function () {
 var chunk;
 while (chunk = process.stdin.read()) {
 	htmlContent += chunk;
 }
});

// Set Browser based on platform
if(process.platform == 'linux') {
	var browserArgs = { executablePath: 'chromium-browser' }
} else {
	var browserArgs = {}
}

(async () => {
  // Prep a browser
  const browser = await puppeteer.launch(browserArgs);
  const page = await browser.newPage();

  // Set viewport size
  await page.setViewport({
  	width: viewWidth,
  	height: viewHeight,
  	deviceScaleFactor: 1,
  });

  // Set page content
  await page.setContent(htmlContent, { waitUntil: ['networkidle0', 'domcontentloaded'] } );
  
  // Take screenshot and emit Base64 version of it
  const img = await page.screenshot();
  console.log(img.toString('base64'));
  
  // Close browser
  await browser.close();
})();