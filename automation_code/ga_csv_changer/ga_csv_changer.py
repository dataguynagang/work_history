import os
import sys
import xlwings as xw
import pandas as pd
import re

# 현재 실행 중인 스크립트 경로를 반환
def get_executable_path():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    else:
        return os.path.dirname(os.path.abspath(__file__))

# 윈도우 파일명에서 사용 불가능한 문자 제거 + 공백은 언더스코어로 치환
def sanitize_filename_part(text):
    text = str(text).strip().lstrip('#').strip()
    text = re.sub(r'[\\/:*?"<>|]', '', text)  # 금지 문자 제거
    return text.replace(' ', '_')

# 작업 디렉토리 설정
current_dir = get_executable_path()

# 대상 CSV 파일 목록 수집
csv_files = [f for f in os.listdir(current_dir) if f.endswith('.csv')]

print(f"총 {len(csv_files)}개의 파일을 확인합니다.")

# 각 CSV 파일 반복 처리
for i, csv_file in enumerate(csv_files, start=1):
    file_path = os.path.join(current_dir, csv_file)

    try:
        # Excel 파일을 xlwings로 열기 (비가시 모드)
        app = xw.App(visible=False)
        wb = xw.Book(file_path)
        sheet = wb.sheets[0]

        # 전체 셀 데이터 읽기
        data = sheet.used_range.value

        # 엑셀 닫기
        wb.close()
        app.quit()

        # 최소 5행, 1열 이상 있어야 유효
        if not data or len(data) < 5 or len(data[0]) < 1:
            print(f"[SKIP] {csv_file} - 데이터 구조 불충분")
            continue

        # GA Explore 포맷 여부 확인
        first_cell = str(data[0][0]).strip()
        if not first_cell.startswith('# ---'):
            print(f"[SKIP] {csv_file} - GA Explore 형식 아님")
            continue

        # 프로퍼티명 / 시트명 추출 + 정제 처리
        property_name = sanitize_filename_part(data[1][0])
        sheet_name = sanitize_filename_part(data[2][0])
        new_filename = f"{property_name}_{sheet_name}.csv"
        new_file_path = os.path.join(current_dir, new_filename)

        # xlwings로 가져온 데이터를 pandas DataFrame으로 변환
        df = pd.DataFrame(data)

        # DataFrame을 utf-8-sig로 저장 (엑셀 호환)
        df.to_csv(new_file_path, index=False, header=False, encoding='utf-8-sig')

        # 원본 파일 삭제 (선택사항: 주석 처리하면 보존됨)
        os.remove(file_path)

        print(f"[SAVE] {new_filename} 생성 완료 (원본 삭제됨)")

    except Exception as e:
        print(f"[ERROR] {csv_file} 처리 중 오류 발생: {e}")

print("모든 파일 처리 완료.")