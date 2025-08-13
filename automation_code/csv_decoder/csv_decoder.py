import os
import sys
import xlwings as xw
import pandas as pd

# 현재 실행 중인 파일의 경로를 안전하게 가져오는 함수
def get_executable_path():
    if getattr(sys, 'frozen', False):
        # PyInstaller로 패키징된 실행 파일일 경우
        return os.path.dirname(sys.executable)
    else:
        # 파이썬 스크립트일 경우
        return os.path.dirname(os.path.abspath(__file__))

# 실행 파일 또는 스크립트가 있는 폴더의 경로
current_dir = get_executable_path()

# 작업 디렉토리에서 모든 CSV 파일을 찾음
csv_files = [f for f in os.listdir(current_dir) if f.endswith('.csv')]

# 처리할 파일의 총 개수 출력
total_files = len(csv_files)
print(f"총 {total_files}개의 파일을 처리합니다.")

# CSV 파일을 xlwings로 열어서 pandas DataFrame으로 저장 후 다시 CSV로 덮어쓰기
for i, csv_file in enumerate(csv_files, start=1):
    file_path = os.path.join(current_dir, csv_file)
    
    # xlwings로 파일 열기
    app = xw.App(visible=False)  # Excel 창을 표시하지 않음
    wb = xw.Book(file_path)  # CSV 파일 열기
    sheet = wb.sheets[0]  # 첫 번째 시트 선택
    
    # 전체 시트 데이터를 pandas DataFrame으로 가져오기 (빈 셀이 있더라도 전체 데이터 포함)
    data = sheet.used_range.value
    df = pd.DataFrame(data)
    
    # Excel 파일 닫기
    wb.close()
    app.quit()
    
    # pandas를 사용하여 동일한 이름의 CSV 파일로 덮어쓰기 (utf-8-sig 인코딩, 헤더 없이 저장)
    df.to_csv(file_path, index=False, header=False, encoding='utf-8-sig')
    
    # 각 파일이 처리될 때 진행 상황 출력
    print(f"{i}번째 파일({csv_file})을 처리했습니다.")

# 모든 파일이 처리되었음을 출력
print(f"완료되었습니다! 총 {total_files}개의 파일을 처리했습니다.")
