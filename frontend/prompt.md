# To Do

Implement an screen that will have:

- a Form with an Input field for an email, this input field must be validated with the validators inside the file validators.dart , this input will have a button a the left side when user clicks this button, you must get the email from the input and pass it to the method UserService.sendemail2 and the button must be disabled while getting a HTTP response 200 from the server. (the email once sent should be saved inside a variable) if the function returns true you should show in the snackbar 'Code was Sent' else 'User not found'

- under the form should be another form with an 3 inputs one for a code of 6 characters(only numbers) and the another 2 must be validated for a password using the validators inside validators.dart also should have a button for send this to the method UserService.forgotPassword() if the function returns true you should show in the snack bar, password changed and send the user to the login screen. else 'Incorrect Code'

<!-- Implement the following methods inside UserService that will: -->
<!---->
<!-- # sendEmail2: -->
<!---->
<!-- parameters: Email -->
<!-- returns: boolean -->
<!---->
<!-- sends an HTTP request of type post to the endpoint `/sendemail2` -->
<!---->
<!-- if response equal 200 returns true -->
<!---->
<!-- # forgotPassword: -->
<!---->
<!-- parameters: email,code,password -->
<!-- returns: boolean -->
<!---->
<!-- send an HTTP request of type Post to the endpoint `/forgotpassword` -->
<!---->
<!-- Returns true if status code 200 -->
