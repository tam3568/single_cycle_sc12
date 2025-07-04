# RISC-V Single Cycle Processor

##  Mục tiêu

Bộ xử lý thực hiện đúng tập lệnh **RV32I** theo kiến trúc **1 chu kỳ (single-cycle)**. Đảm bảo pass toàn bộ test **SC1 và SC2** từ hệ thống chấm điểm tự động
## Cấu trúc thư mục
```text
├── RISCV_Single_Cycle.v # Top module
├── control_unit.v       # Bộ điều khiển tập lệnh
├── ALU.v                # ALU (gộp luôn ALU decoder)
├── Branch_Comp.v        # So sánh điều kiện nhánh
├── DMEM.v               # Data memory
├── IMEM.v               # Instruction memory
├── Imm_Gen.v            # Immediate Generator
├── PC.v                 # Bộ đếm chương trình
├── RegisterFile.v       # Bộ thanh ghi
├── kquasc1              # kết quả với sc1
├── kquasc2              # kết quả với sc2
```
## Lệnh để kiểm tra
python3 /srv/calab_grade/CA_Lab-2025/scripts/calab_grade.py sc1 ALU.v ALU_decoder.v Branch_Comp.v DMEM.v IMEM.v Imm_Gen.v RegisterFile.v control_unit.v PC.v RISCV_Single_Cycle.v
single_cycle_sc2

python3 /srv/calab_grade/CA_Lab-2025/scripts/calab_grade.py sc2 ALU.v ALU_decoder.v Branch_Comp.v DMEM.v IMEM.v Imm_Gen.v RegisterFile.v control_unit.v PC.v RISCV_Single_Cycle.v
single_cycle_sc2 

## Lệnh để xem kết quả
cd /tmp/grade_tampham

cat sim.log