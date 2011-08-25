$(function() {
  Stripe.publishableKey = "pk_dl4LcpeAxUEPHN3FxzuAQQmhCGmx5";

  $("#new_user").submit(function() {
    var form = this;
    $("#user_submit").attr("disabled", true);
    $("#credit-card-errors").hide();

    if (!$("#credit-card").is(":visible")) {
      $("#credit-card input").attr("disabled", true);
      return true;
    }
    
    var card = {
      number: $("#credit_card_number").val(),
      expMonth: $("#_expiry_date_2i").val(),
      expYear: $("#_expiry_date_1i").val()
    };


    Stripe.createToken(card, function(status, response) {
      if (status === 200) {
        $("#user_stripe_token").val(response.id);
        $("#credit-card input").attr("disabled", true);
        form.submit();
      } else {
        $("#stripe-error-message").text(response.error.message);
        $("#credit-card-errors").show();
        $("#user_submit").attr("disabled", false);
      }
    });

    return false;
  });

  $("#change-card").click(function() {
    $(this).hide();
    $("#credit-card").show();
    return false;
  });
});
