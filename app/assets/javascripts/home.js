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
    flickrSets: [{
          setId: '72157633836081300',
          apiKey: 'bb8ba80ac9f7b4da1e58e45e55ae6d6a'
        },
        {
          setId: '72157633834703987',
          apiKey: 'bb8ba80ac9f7b4da1e58e45e55ae6d6a'
        }],
    flickrOptions: {
      useTitle: true,
      imageSize: 'l'
    },
    lightbox:true,
    initialHeight:1200
  });
});
