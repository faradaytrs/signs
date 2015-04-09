<?php
require 'PHPMailer/PHPMailerAutoload.php';

$postdata = file_get_contents("php://input");
$request = json_decode($postdata);

$client = yaml_emit(json_decode($request->client, true), YAML_UTF8_ENCODING);
$models = yaml_emit(json_decode($request->models, true), YAML_UTF8_ENCODING);

$mail = new PHPMailer;

$mail->isSMTP();
$mail->Host = 'smtp.gmail.com';
$mail->SMTPAuth = true;
$mail->Username = 'faradaytrs@gmail.com';
$mail->Password = 'OrodruinGotBroken1';
$mail->SMTPSecure = 'tls';
$mail->Port = 587;

$mail->From = 'from@example.com';
$mail->FromName = 'Mailer';
$mail->addAddress('faradaytrs@gmail.com', 'Joe User');

$mail->isHTML(false);

$mail->Subject = 'New Sign Order';
$mail->Body = $client . $models;

if (!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
    echo 'Message has been sent';
}