### mod from HAvsFunc
### 抗抖动脚本（此类问题常见于胶片转录作品），CPU开销很大

import vapoursynth as vs
from vapoursynth import core

input = video_in

threshold = 255 << (input.format.bits_per_sample - 8)
temp = input.focus2.TemporalSoften2(7, threshold, threshold, 25, 2)
inter = core.std.Interleave([core.rgvs.Repair(temp, input.focus2.TemporalSoften2(1, threshold, threshold, 25, 2), mode=[1]), input])
mdata = inter.mv.DepanEstimate(trust=0, dxmax=4, dymax=4)
mdata_fin = inter.mv.DepanCompensate(data=mdata, offset=-1, mirror=15)
output = mdata_fin[::2]

output.set_output()
