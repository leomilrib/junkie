$(function() {
  $('span.icon.ready').each(function(){
    $(this).prop('title', 'This is ready')
  })

  $('span.icon.pending').each(function(){
    $(this).prop('title', 'This is pending')
  })
})