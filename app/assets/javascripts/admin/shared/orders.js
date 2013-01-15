function rm_if_new_record(check_tag){
  if (check_tag.name == undefined){
    return;
  }
  var rid = check_tag.name.match(/\[(\d+)\]/);
  if (rid.length > 1 && parseInt(rid[1]) > 100 ){
    $(check_tag).closest('div.container').slideUp('slow', function(){
      $(this).remove();
    });
  }
}
