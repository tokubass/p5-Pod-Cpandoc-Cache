requires 'perl', '5.008001';
requires 'Pod::Cpandoc', '0';
requires 'Class::Method::Modifiers','0';
requires 'Time::Piece', '1.16';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Capture::Tiny', '0';
    requires 'File::Temp', '0';
};

