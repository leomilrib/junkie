$(function() {
  $('span.loading').each(function(){
    var span = $(this)

    $.ajax({
      url: '/pull_icons',
      type: 'GET',
      data: {
        org: span.data('org'),
        repo: span.data('repo'),
        number: span.data('number')
      },
    }).done(function(result) {
      span.parents('div.icon-container').html(result)
      defineIconTitles()
    })
  })

  var defineIconTitles = function(){
    $('span.icon.ready').each(function(){
      $(this).prop('title', 'This is ready')
    })
    $('span.icon.pending').each(function(){
      $(this).prop('title', 'This is pending')
    })
  }
})