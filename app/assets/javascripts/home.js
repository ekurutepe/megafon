//= require lightbox.min
//= require rfg


$(document).ready(function () {
  $('#myGallery').rfg({
    imageWidth:350,
    center:true,
    spacing:5,
    categories:false,
    categoryOptions:{
      defaultCategory:'All',
      includeAll: true
    },
    flickrOptions: {
      imageSize: 'l'
    },
    lightbox:true,
    initialHeight:1200
  });
});
