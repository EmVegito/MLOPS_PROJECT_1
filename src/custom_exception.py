import traceback #tracking an error
import sys

class CustomException(Exception):

    def __init__(self, error_message, error_detail: sys):
        super().__init__(error_message)
        self.error_message = self.get_detailed_error_message(error_message, error_detail)

    @staticmethod #We are able to use our class without creating an object
    def get_detailed_error_message(error_message, error_detail: sys):

        _ , _ , exc_tb = traceback.sys.exc_info()
        file_name = exc_tb.tb_frame.f_code.co_filename
        line_number = exc_tb.tb_lineno

        return f"Error in {file_name}, line {line_number} : {error_message}"
    
    def __str__(self):
        # Gives text representation of error message usage str(e) e is Exception
        return self.error_message