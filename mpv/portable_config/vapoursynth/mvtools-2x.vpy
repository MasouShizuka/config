### mvtools倍帧，一般开销

import vapoursynth as vs
from vapoursynth import core

input = video_in


recal = 1
interp_mode = 2
dfps = container_fps * 2 * 1000
# 优化首次分析 0 否 1 是
# 运动补偿模式 1=Flow // 2=Block
# 目标帧率即 dfps/1000

if container_fps > 32 :
	raise Warning("源帧率超过限制的范围，已临时禁用该脚本。")

cut1 = core.std.AssumeFPS(clip=input, fpsnum=int(container_fps * 1000), fpsden=1000)
cut_s = core.mv.Super(clip=cut1, pel=1, sharp=0)
cut_b = core.mv.Analyse(super=cut_s, blksize=32, isb=True, search=2)
cut_f = core.mv.Analyse(super=cut_s, blksize=32, search=2)

if recal == 0 :
	cut_b, cut_f = cut_b, cut_f
if recal == 1 :
	cut_b = core.mv.Recalculate(super=cut_s, vectors=cut_b, blksize=16, search=2, searchparam=1, thsad=200)
	cut_f = core.mv.Recalculate(super=cut_s, vectors=cut_f, blksize=16, search=2, searchparam=1, thsad=200)

if interp_mode == 1 :
	output = core.mv.FlowFPS(clip=cut1, super=cut_s, mvbw=cut_b, mvfw=cut_f, num=dfps, den=1000, mask=1)
if interp_mode == 2 :
	output = core.mv.BlockFPS(clip=cut1, super=cut_s, mvbw=cut_b, mvfw=cut_f, num=dfps, den=1000)

output.set_output()
