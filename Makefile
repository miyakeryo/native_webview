.PHONY: all test clean

generate_test_file:
	cd example; dart ./test_driver/generate_test_file.dart

test:
	cd example; flutter test integration_test

testci:
	cd example; flutter test $(TARGET)
