//= require jquery.colorbox
//= require rfg

$(document).ready(function () {
  SC.initialize({
    client_id: '2826b6e0008b427559ece94781493083'
  });
  
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
