/* resolver.vala
 *
 * Copyright (C) 2010  Luca Bruno
 *
 * This file is part of Mipsdis.
 *
 * Mipsdis is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * Mipsdis is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Mipsdis.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *      Luca Bruno <lethalman88@gmail.com>
 */

namespace Mips
{
  public class SymbolResolver : Visitor
  {
    private BinaryInstruction current_binary_instruction;
    private BinaryCode binary_code;
    private Register loaded_register;
    private int16 loaded_gp_offset;
    private int next_label;

    public SymbolResolver (BinaryCode binary_code)
      {
        this.binary_code = binary_code;
      }
    
    public void resolve ()
    {
      foreach (var binary_instruction in binary_code.text_section.binary_instructions)
      {
        current_binary_instruction = binary_instruction;
        binary_instruction.instruction.accept (this);
      }
    }

    private BinaryReference get_rodata_reference (int16 gp_offset, uint16 initial_offset)
    {
      var initial = binary_code.plt_table.get_initial_for_gp_offset (gp_offset);
      if (!binary_code.address_mapping.has_physical_address (initial))
        return new BinaryAddress (initial + initial_offset);

      var file_offset = binary_code.address_mapping.get_physical_address (initial) + initial_offset;
      var str = binary_code.readonly_data.string_at_address (file_offset);
      if (str == null)
        return new BinaryAddress (file_offset);

      return new BinaryString (file_offset, str);
    }

    private BinaryReference? get_gpr_reference (Register register, int16 offset)
    {
      if (register == Register.GP)
        {
          bool is_local;
          var symbol = binary_code.symbol_table.symbol_at_gp_offset (offset, out is_local);

          if (symbol == null || is_local)
            {
              var initial = binary_code.plt_table.get_initial_for_gp_offset (offset);
              return new BinaryPltInitial (initial);
            }
          else
            {
              if (symbol.info == Symbol.Info.FUNC && symbol.value != 0)
                {
                  var binary_instruction = binary_code.text_section.instruction_at_address (symbol.value);
                  if (binary_instruction != null)
                    {
                      if (binary_instruction.label == null)
                        {
                          var str = binary_code.string_table.string_at_offset (symbol.name);
                          binary_instruction.label = str;
                        }
                      binary_instruction.is_func_start = true;
                      return binary_instruction;
                    }
                }
              else if (symbol.info == Symbol.Info.OBJECT && symbol.name != 0)
                {
                  var str = binary_code.string_table.string_at_offset (symbol.name);
                  return new BinaryObject (str);
                }
            }
        }
      return null;
    }

    private BinaryInstruction? get_branch_at_offset (int16 offset)
    {
      var address = current_binary_instruction.virtual_address + (offset << 2);
      var binary_instruction = binary_code.text_section.instruction_at_address (address);
      if (binary_instruction == null)
        return null;

      if (binary_instruction.label == null)
        binary_instruction.label = ".L%d".printf (next_label++);
      return binary_instruction;
    }

    public override void visit_cop0_eret (Cop0.Eret inst)
    {
    }
    public override void visit_cop0_deret (Cop0.Deret inst)
    {
    }
    public override void visit_cop0_mf (Cop0.Mf inst)
    {
    }
    public override void visit_cop0_mt (Cop0.Mt inst)
    {
    }
    public override void visit_cop1_abs (Cop1.Abs inst)
    {
    }
    public override void visit_cop1_cf (Cop1.Cf inst)
    {
    }
    public override void visit_cop1_ct (Cop1.Ct inst)
    {
    }
    public override void visit_cop2_cf (Cop2.Cf inst)
    {
    }
    public override void visit_cop2_ct (Cop2.Ct inst)
    {
    }
    public override void visit_cop2_mf (Cop2.Mf inst)
    {
    }
    public override void visit_cop2_mfh (Cop2.Mfh inst)
    {
    }
    public override void visit_cop2_mth (Cop2.Mth inst)
    {
    }
    public override void visit_cop1_sqrt (Cop1.Sqrt inst)
    {
    }
    public override void visit_cop1_mov (Cop1.Mov inst)
    {
    }
    public override void visit_cop1_movn (Cop1.Movn inst)
    {
    }
    public override void visit_cop1_neg (Cop1.Neg inst)
    {
    }
    public override void visit_cop1_sub (Cop1.Sub inst)
    {
    }
    public override void visit_cop1_mul (Cop1.Mul inst)
    {
    }
    public override void visit_cop1_div (Cop1.Div inst)
    {
    }
    public override void visit_cop1_truncw (Cop1.Truncw inst)
    {
    }
    public override void visit_cop1_ceilw (Cop1.Ceilw inst)
    {
    }
    public override void visit_cop1_ceill (Cop1.Ceill inst)
    {
    }
    public override void visit_cop1_floorw (Cop1.Floorw inst)
    {
    }
    public override void visit_cop1_floorl (Cop1.Floorl inst)
    {
    }
    public override void visit_cop1_roundl (Cop1.Roundl inst)
    {
    }
    public override void visit_cop1_roundw (Cop1.Roundw inst)
    {
    }
    public override void visit_cop1_rsqrt (Cop1.Rsqrt inst)
    {
    }
    public override void visit_cop1_cvtd (Cop1.Cvtd inst)
    {
    }
    public override void visit_cop1_cvtl (Cop1.Cvtl inst)
    {
    }
    public override void visit_cop1_cvtps (Cop1.Cvtps inst)
    {
    }
    public override void visit_cop1_cvtw (Cop1.Cvtw inst)
    {
    }
    public override void visit_cop1_cvts (Cop1.Cvts inst)
    {
    }
    public override void visit_cop1_cvtspl (Cop1.Cvtspl inst)
    {
    }
    public override void visit_cop1_cvtspu (Cop1.Cvtspu inst)
    {
    }
    public override void visit_cop1_add (Cop1.Add inst)
    {
    }
    public override void visit_cop1_pll (Cop1.Pll inst)
    {
    }
    public override void visit_cop1_plu (Cop1.Plu inst)
    {
    }
    public override void visit_cop1_pul (Cop1.Pul inst)
    {
    }
    public override void visit_cop1_puu (Cop1.Puu inst)
    {
    }
    public override void visit_cop1_ccond (Cop1.Ccond inst)
    {
    }
    public override void visit_cop1_bc (Cop1.Bc inst)
    {
    }
    public override void visit_cop1_movz (Cop1.Movz inst)
    {
    }
    public override void visit_cop2_bc (Cop2.Bc inst)
    {
    }
    public override void visit_cop2_co (Cop2.Co inst)
    {
    }
    public override void visit_cop2_mt (Cop2.Mt inst)
    {
    }
    public override void visit_cop1_mt (Cop1.Mt inst)
    {
    }
    public override void visit_cop1_mf (Cop1.Mf inst)
    {
    }
    public override void visit_cop1_mfh (Cop1.Mfh inst)
    {
    }
    public override void visit_cop1_mth (Cop1.Mth inst)
    {
    }
    public override void visit_cop1_recip (Cop1.Recip inst)
    {
    }
    public override void visit_movci (Movci inst)
    {
    }
    public override void visit_cop1_movcf (Cop1.Movcf inst)
    {
    }
    public override void visit_cop1x_madd (Cop1x.Madd inst)
    {
    }
    public override void visit_cop1x_nmadd (Cop1x.Nmadd inst)
    {
    }
    public override void visit_cop1x_nmsub (Cop1x.Nmsub inst)
    {
    }
    public override void visit_cop1x_msub (Cop1x.Msub inst)
    {
    }
    public override void visit_cop1x_prefx (Cop1x.Prefx inst)
    {
    }
    public override void visit_jump (Jump inst)
    {
    }
    public override void visit_jal (Jal inst)
    {
    }
    public override void visit_sdbbp (Sdbbp inst)
    {
    }
    public override void visit_syscall (Syscall inst)
    {
    }
    public override void visit_add (Add inst)
    {
    }
    public override void visit_lui (Lui inst)
    {
    }
    public override void visit_addiu (Addiu inst)
    {
      if (inst.rt == loaded_register)
        {
          if (inst.rs == loaded_register)
            {
              // maybe read only data
              inst.reference = get_rodata_reference (loaded_gp_offset, inst.immediate);
            }
          loaded_register = Register.ZERO;
          loaded_gp_offset = 0;
        }
    }
    public override void visit_addi (Addi inst)
    {
    }
    public override void visit_addu (Addu inst)
    {
    }
    public override void visit_sub (Sub inst)
    {
    }
    public override void visit_subu (Subu inst)
    {
    }
    public override void visit_cop0_rdpgpr (Cop0.Rdpgpr inst)
    {
    }
    public override void visit_cop0_mfmc0 (Cop0.Mfmc0 inst)
    {
    }
    public override void visit_sw (Sw inst)
    {
    }
    public override void visit_cache (Cache inst)
    {
    }
    public override void visit_pref (Pref inst)
    {
    }
    public override void visit_sync (Sync inst)
    {
    }
    public override void visit_regimm_synci (Regimm.Synci inst)
    {
    }
    public override void visit_ext (Ext inst)
    {
    }
    public override void visit_ins (Ins inst)
    {
    }
    public override void visit_swl (Swl inst)
    {
    }
    public override void visit_swr (Swr inst)
    {
    }
    public override void visit_lb (Lb inst)
    {
    }
    public override void visit_ll (Ll inst)
    {
    }
    public override void visit_sh (Sh inst)
    {
    }
    public override void visit_lh (Lh inst)
    {
    }
    public override void visit_regimm_bgezal (Regimm.Bgezal inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bgezall (Regimm.Bgezall inst)
    {
    }
    public override void visit_lw (Lw inst)
    {
      inst.reference = get_gpr_reference (inst.@base, inst.offset);
      if (!(inst.reference is BinaryInstruction) && inst.@base == Register.GP && inst.rt != Register.GP)
        {
          // maybe ready only data
          loaded_register = inst.rt;
          loaded_gp_offset = inst.offset;
        }
    }
    public override void visit_lwl (Lwl inst)
    {
    }
    public override void visit_lwr (Lwr inst)
    {
    }
    public override void visit_jalr (Jalr inst)
    {
    }
    public override void visit_jr (Jr inst)
    {
    }
    public override void visit_regimm_bltzal (Regimm.Bltzal inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bltzall (Regimm.Bltzall inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bgez (Regimm.Bgez inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bgezl (Regimm.Bgezl inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bltz (Regimm.Bltz inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_regimm_bltzl (Regimm.Bltzl inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_sll (Sll inst)
    {
    }
    public override void visit_sra (Sra inst)
    {
    }
    public override void visit_srl (Srl inst)
    {
    }
    public override void visit_beq (Beq inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_beql (Beql inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_bne (Bne inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_bnel (Bnel inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_lbu (Lbu inst)
    {
    }
    public override void visit_sb (Sb inst)
    {
    }
    public override void visit_seb (Seb inst)
    {
    }
    public override void visit_seh (Seh inst)
    {
    }
    public override void visit_sc (Sc inst)
    {
    }
    public override void visit_rdhwr (Rdhwr inst)
    {
    }
    public override void visit_sltiu (Sltiu inst)
    {
    }
    public override void visit_slti (Slti inst)
    {
    }
    public override void visit_ori (Ori inst)
    {
    }
    public override void visit_andi (Andi inst)
    {
    }
    public override void visit_sltu (Sltu inst)
    {
    }
    public override void visit_mult (Mult inst)
    {
    }
    public override void visit_div (Div inst)
    {
    }
    public override void visit_slt (Slt inst)
    {
    }
    public override void visit_sllv (Sllv inst)
    {
    }
    public override void visit_and (And inst)
    {
    }
    public override void visit_or (Or inst)
    {
    }
    public override void visit_lhu (Lhu inst)
    {
    }
    public override void visit_mfhi (Mfhi inst)
    {
    }
    public override void visit_mthi (Mthi inst)
    {
    }
    public override void visit_mflo (Mflo inst)
    {
    }
    public override void visit_mtlo (Mtlo inst)
    {
    }
    public override void visit_multu (Multu inst)
    {
    }
    public override void visit_blez (Blez inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_blezl (Blezl inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_bgtz (Bgtz inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_bgtzl (Bgtzl inst)
    {
      inst.reference = get_branch_at_offset (inst.offset);
    }
    public override void visit_xori (Xori inst)
    {
    }
    public override void visit_clo (Clo inst)
    {
    }
    public override void visit_clz (Clz inst)
    {
    }
    public override void visit_mul (Mul inst)
    {
    }
    public override void visit_nor (Nor inst)
    {
    }
    public override void visit_xor (Xor inst)
    {
    }
    public override void visit_srlv (Srlv inst)
    {
    }
    public override void visit_srav (Srav inst)
    {
    }
    public override void visit_divu (Divu inst)
    {
    }
    public override void visit_break (Break inst)
    {
    }
    public override void visit_movz (Movz inst)
    {
    }
    public override void visit_movn (Movn inst)
    {
    }
    public override void visit_madd (Madd inst)
    {
    }
    public override void visit_msub (Msub inst)
    {
    }
    public override void visit_msubu (Msubu inst)
    {
    }
    public override void visit_maddu (Maddu inst)
    {
    }
    public override void visit_sdc1 (Sdc1 inst)
    {
    }
    public override void visit_sdc2 (Sdc2 inst)
    {
    }
    public override void visit_cop1x_alnv (Cop1x.Alnv inst)
    {
    }
    public override void visit_cop1x_sdxc1 (Cop1x.Sdxc1 inst)
    {
    }
    public override void visit_cop1x_suxc1 (Cop1x.Suxc1 inst)
    {
    }
    public override void visit_cop1x_ldxc1 (Cop1x.Ldxc1 inst)
    {
    }
    public override void visit_cop1x_luxc1 (Cop1x.Luxc1 inst)
    {
    }
    public override void visit_cop1x_lwxc1 (Cop1x.Lwxc1 inst)
    {
    }
    public override void visit_cop1x_swxc1 (Cop1x.Swxc1 inst)
    {
    }
    public override void visit_ldc1 (Ldc1 inst)
    {
    }
    public override void visit_ldc2 (Ldc2 inst)
    {
    }
    public override void visit_lwc1 (Lwc1 inst)
    {
    }
    public override void visit_lwc2 (Lwc2 inst)
    {
    }
    public override void visit_swc1 (Swc1 inst)
    {
    }
    public override void visit_swc2 (Swc2 inst)
    {
    }
    public override void visit_teq (Teq inst)
    {
    }
    public override void visit_regimm_teqi (Regimm.Teqi inst)
    {
    }
    public override void visit_tge (Tge inst)
    {
    }
    public override void visit_regimm_tgei (Regimm.Tgei inst)
    {
    }
    public override void visit_regimm_tgeiu (Regimm.Tgeiu inst)
    {
    }
    public override void visit_tgeu (Tgeu inst)
    {
    }
    public override void visit_cop0_tlbp (Cop0.Tlbp inst)
    {
    }
    public override void visit_cop0_tlbr (Cop0.Tlbr inst)
    {
    }
    public override void visit_cop0_tlbwi (Cop0.Tlbwi inst)
    {
    }
    public override void visit_cop0_tlbwr (Cop0.Tlbwr inst)
    {
    }
    public override void visit_tlt (Tlt inst)
    {
    }
    public override void visit_regimm_tlti (Regimm.Tlti inst)
    {
    }
    public override void visit_regimm_tltiu (Regimm.Tltiu inst)
    {
    }
    public override void visit_tltu (Tltu inst)
    {
    }
    public override void visit_tne (Tne inst)
    {
    }
    public override void visit_regimm_tnei (Regimm.Tnei inst)
    {
    }
    public override void visit_cop1_truncl (Cop1.Truncl inst)
    {
    }
    public override void visit_cop0_wait (Cop0.Wait inst)
    {
    }
    public override void visit_cop0_wrpgpr (Cop0.Wrpgpr inst)
    {
    }
    public override void visit_wsbh (Wsbh inst)
    {
    }
  }
}