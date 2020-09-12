let downloadImage = function(options) {
  domtoimage.toBlob(document.getElementById(options.id))
      .then(function (blob) {
          window.saveAs(blob, `${options.name}.png`);
          console.log("done");
      });
}
Shiny.addCustomMessageHandler('downloadImage', downloadImage)
