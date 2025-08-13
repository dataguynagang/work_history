import os
import sys

# 현재 폴더 경로를 지정합니다.
# .py 파일로 실행할 때는 __file__ 변수를 사용하고, .exe로 실행할 때는 os.getcwd()를 사용합니다.
if getattr(sys, 'frozen', False):
    # .exe로 실행된 경우
    folder_path = os.getcwd()
else:
    # .py 파일로 직접 실행된 경우
    folder_path = os.path.dirname(os.path.abspath(__file__))

# 폴더 내 모든 CSV 파일을 가져옵니다.
csv_files = [f for f in os.listdir(folder_path) if f.endswith('.csv')]
total_files = len(csv_files)

# 변경할 파일 수를 알리는 시작 메시지 출력
print(f"총 {total_files}개의 파일명을 변경합니다.\n")

# 파일명 변경 과정
for filename in csv_files:
    # 'P4 WEB - Korea' 뒤의 문자를 제거한 새로운 파일명을 생성합니다.
    if 'P4 WEB - Korea' in filename:
        new_filename = filename.split('P4 WEB - Korea')[0].strip() + 'P4 WEB - Korea.csv'
    else:
        new_filename = filename  # 'P4 WEB - Korea'가 없으면 변경하지 않음
    
    # 기존 파일 경로와 새로운 파일 경로를 지정합니다.
    old_file_path = os.path.join(folder_path, filename)
    new_file_path = os.path.join(folder_path, new_filename)
    
    # 파일명을 변경하고 변경 사항을 출력합니다.
    if old_file_path != new_file_path:  # 변경이 필요한 경우만
        os.rename(old_file_path, new_file_path)
        print(f"'{filename}'을(를) '{new_filename}'으로 변경했습니다.")

# 최종 완료 메시지 출력
print(f"\n총 {total_files}개의 파일명을 변경 완료했습니다.")