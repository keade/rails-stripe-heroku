$(function() {
  $("#new_user").submit(function() {
    alert("hi");
    $("#user_submit").attr("disabled", true);
    return false;
  });
});
