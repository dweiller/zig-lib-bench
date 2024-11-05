pub const distribution: [4097]f64 = d ++ (.{0} ** (4097 - d.len));
const d = [_]f64{ 0.0407952,0.0284411,0.0551473,0.0453488,0.0286775,0.0454336,0.0477906,0.0177038,0.0739862,0.0328743,0.0235062,0.016872,0.0248531,0.013779,0.0116962,0.0175477,0.0292885,0.0197353,0.0103471,0.0188099,0.0136252,0.010918,0.00971601,0.00969148,0.0202147,0.00899127,0.00724966,0.0243915,0.00441313,0.00599418,0.00633537,0.0106905,0.0276629,0.00515125,0.0117654,0.00617927,0.0068661,0.00601648,0.00826207,0.00341187,0.00306399,0.00671223,0.00413438,0.00415222,0.00339849,0.00202259,0.00517132,0.00500407,0.00601871,0.00244406,0.00378873,0.00242845,0.00351221,0.00279193,0.00137144,0.00270719,0.00494163,0.0022612,0.00173938,0.00156098,0.00160781,0.00240392,0.00229911,0.00192001,0.0090381,0.00167248,0.00290566,0.00102356,0.00163011,0.00254663,0.00113283,0.000938821,0.00216754,0.00136029,0.00111499,0.00123541,0.000628854,0.000885301,0.000515125,0.000497285,0.00196684,0.000566414,0.00142942,0.000461605,0.000818402,0.000421466,0.000590944,0.000874151,0.000909831,0.000570874,0.000412546,0.000479445,0.000343417,0.000316657,0.000178398,0.000454915,0.00095889,0.000283207,0.000597634,0.000345647,0.000314427,0.000144949,0.000205158,0.000787182,0.000434846,0.000236378,0.000269827,0.000486135,0.000147179,0.000194008,0.000207388,0.000122649,0.000359026,0.000156098,0.000613244,0.000352336,0.000769342,0.000153868,0.000191778,0.000200698,0.000332267,0.000133799,0.000225228,0.000178398,0.000129339,0.000144949,0.000158328,0.000165018,0.00293242,9.8119e-05,0.000104809,0.000205158,8.47391e-05,6.24394e-05,7.80492e-05,0.000156098,0.000272057,0.000131569,9.5889e-05,4.23696e-05,9.36591e-05,4.45996e-05,0.000113729,8.47391e-05,0.000102579,0.000102579,6.68993e-05,7.58192e-05,8.69691e-05,7.58192e-05,9.36591e-05,3.34497e-05,7.35893e-05,6.24394e-05,4.45996e-05,9.5889e-05,6.02094e-05,7.13593e-05,4.45996e-05,4.45996e-05,0.000434846,4.23696e-05,2.22998e-05,7.80492e-05,4.23696e-05,9.14291e-05,9.36591e-05,5.12895e-05,8.47391e-05,4.01396e-05,2.67597e-05,7.58192e-05,5.35195e-05,4.01396e-05,2.67597e-05,3.34497e-05,0.000176168,5.12895e-05,2.67597e-05,6.02094e-05,3.56796e-05,9.14291e-05,2.67597e-05,7.13593e-05,8.02792e-05,3.34497e-05,1.78398e-05,2.89897e-05,0.000350106,8.69691e-05,4.90595e-05,9.5889e-05,0.000198468,2.67597e-05,5.12895e-05,5.57494e-05,3.56796e-05,5.35195e-05,3.79096e-05,3.34497e-05,0.000180628,3.79096e-05,5.12895e-05,2.89897e-05,3.34497e-05,6.91293e-05,0.000405856,5.79794e-05,4.45996e-05,6.02094e-05,0.000129339,3.56796e-05,2.00698e-05,2.67597e-05,1.11499e-05,2.22998e-05,6.46694e-05,2.00698e-05,2.89897e-05,1.33799e-05,2.89897e-05,3.12197e-05,3.12197e-05,4.23696e-05,0.000165018,2.00698e-05,1.78398e-05,4.90595e-05,1.56098e-05,2.00698e-05,4.23696e-05,2.45298e-05,0.000445996,3.79096e-05,2.89897e-05,1.78398e-05,1.11499e-05,1.33799e-05,2.89897e-05,1.56098e-05,4.23696e-05,3.12197e-05,2.22998e-05,2.67597e-05,4.23696e-05,2.22998e-05,6.24394e-05,3.12197e-05,3.34497e-05,2.22998e-05,3.34497e-05,1.78398e-05,0.00665425,2.89897e-05,6.02094e-05,2.67597e-05,0.0161763,2.89897e-05,1.33799e-05,3.79096e-05,1.11499e-05,3.34497e-05,8.02792e-05,2.45298e-05,0.000312197,3.12197e-05,3.34497e-05,2.45298e-05,3.12197e-05,3.34497e-05,1.11499e-05,0.000187318,0.000169478,1.33799e-05,1.33799e-05,2.45298e-05,2.67597e-05,1.56098e-05,2.22998e-05,2.00698e-05,6.24394e-05,2.00698e-05,2.00698e-05,2.67597e-05,4.23696e-05,2.89897e-05,1.78398e-05,6.02094e-05,3.79096e-05,4.01396e-05,3.34497e-05,2.67597e-05,1.78398e-05,1.11499e-05,1.78398e-05,1.56098e-05,1.78398e-05,1.78398e-05,3.79096e-05,3.79096e-05,7.13593e-05,1.78398e-05,2.22998e-05,2.00698e-05,8.91991e-06,2.45298e-05,2.45298e-05,1.78398e-05,2.00698e-05,5.12895e-05,7.80492e-05,1.78398e-05,6.68993e-06,2.45298e-05,2.00698e-05,3.12197e-05,1.11499e-05,6.68993e-06,2.00698e-05,4.45996e-05,1.78398e-05,2.22998e-05,3.12197e-05,2.89897e-05,2.67597e-05,4.23696e-05,2.00698e-05,1.56098e-05,3.56796e-05,4.68295e-05,1.78398e-05,1.33799e-05,3.12197e-05,1.78398e-05,2.67597e-05,6.68993e-06,6.68993e-06,1.11499e-05,8.91991e-06,2.45298e-05,2.89897e-05,4.45996e-06,1.33799e-05,1.78398e-05,1.56098e-05,1.33799e-05,1.78398e-05,1.11499e-05,8.91991e-06,1.56098e-05,1.56098e-05,2.67597e-05,3.79096e-05,8.91991e-06,8.91991e-06,1.56098e-05,8.91991e-06,1.78398e-05,3.79096e-05,1.56098e-05,2.00698e-05,1.78398e-05,4.01396e-05,6.68993e-06,1.78398e-05,8.91991e-06,2.00698e-05,1.11499e-05,1.56098e-05,1.56098e-05,3.12197e-05,2.67597e-05,1.56098e-05,1.56098e-05,2.45298e-05,2.00698e-05,1.78398e-05,3.12197e-05,2.00698e-05,6.68993e-06,2.89897e-05,1.33799e-05,1.78398e-05,3.34497e-05,6.02094e-05,0,3.56796e-05,0,2.00698e-05,0,1.11499e-05,0,2.22998e-05,0,2.67597e-05,0,3.79096e-05,0,9.14291e-05,0,3.34497e-05,0,4.23696e-05,0,3.79096e-05,0,0.000129339,0,3.79096e-05,0,2.22998e-05,0,4.68295e-05,0,1.78398e-05,0,4.23696e-05,0,3.56796e-05,0,2.22998e-05,0,1.33799e-05,0,3.56796e-05,0,0.000107039,0,3.79096e-05,0,1.78398e-05,0,2.45298e-05,0,2.89897e-05,0,1.56098e-05,0,2.22998e-05,0,2.67597e-05,0,2.67597e-05,0,3.56796e-05,0,2.22998e-05,0,0.000220768,0,2.67597e-05,0,4.23696e-05,0,4.68295e-05,0,1.33799e-05,0,2.67597e-05,0,1.56098e-05,0,2.67597e-05,0,1.78398e-05,0,2.45298e-05,0,3.12197e-05,0,0.000127109,0,6.68993e-06,0,4.23696e-05,0,2.00698e-05,0,3.12197e-05,0,2.22998e-05,0,2.45298e-05,0,8.91991e-06,0,1.11499e-05,0,2.22998e-05,0,0.000109269,0,1.78398e-05,0,2.22998e-05,0,2.00698e-05,0,3.12197e-05,0,1.78398e-05,0,6.68993e-06,0,5.35195e-05,0,1.33799e-05,0,3.79096e-05,0,1.78398e-05,0,0.00227235,0,0.000122649,0,1.11499e-05,0,2.22998e-05,0,1.33799e-05,0,2.22998e-05,0,3.34497e-05,0,0.000127109,0,1.78398e-05,0,3.56796e-05,0,8.25092e-05,0,2.67597e-05,0,4.45996e-05,0,6.02094e-05,0,5.79794e-05,0,1.33799e-05,0,0.000403626,0,0.000111499,0,3.34497e-05,0,2.22998e-05,0,4.68295e-05,0,8.91991e-05,0,0.000113729,0,4.45996e-06,0,6.68993e-06,0,1.56098e-05,0,8.91991e-06,0,2.67597e-05,0,0.000131569,0,2.00698e-05,0,1.56098e-05,0,0.000256447,0,0.000243068,0,0.000359026,0,1.33799e-05,0,1.56098e-05,0,2.67597e-05,0,2.22998e-05,0,1.78398e-05,0,8.02792e-05,0,2.22998e-05,0,4.01396e-05,0,1.56098e-05,0,4.23696e-05,0,8.91991e-06,0,1.11499e-05,0,0.000187318,0,6.46694e-05,0,7.58192e-05,0,0.000129339,0,1.56098e-05,0,0.000109269,0,0.000209618,0,6.24394e-05,0,1.56098e-05,0,4.01396e-05,0,8.91991e-06,0,8.91991e-06,0,2.00698e-05,0,4.45996e-06,0,2.22998e-05,0,1.33799e-05,0,8.91991e-06,0,1.56098e-05,0,2.45298e-05,0,0,3.12197e-05,0,0,2.22998e-05,0,0,2.89897e-05,0,0,4.01396e-05,0,0,1.11499e-05,0,0,3.34497e-05,0,0,0.000200698,0,0,5.35195e-05,0,0,7.35893e-05,0,0,6.02094e-05,0,0,3.56796e-05,0,0,2.00698e-05,0,0,2.67597e-05,0,0,1.33799e-05,0,0,1.11499e-05,0,0,4.23696e-05,0,0,2.89897e-05,0,0,2.22998e-05,0,0,1.11499e-05,0,0,2.00698e-05,0,0,1.56098e-05,0,0,1.33799e-05,0,0,1.56098e-05,0,0,1.78398e-05,0,0,2.22998e-05,0,0,1.78398e-05,0,0,4.45996e-06,0,0,1.78398e-05,0,0,1.33799e-05,0,0,1.78398e-05,0,0,8.91991e-06,0,0,2.00698e-05,0,0,1.56098e-05,0,0,1.11499e-05,0,0,1.78398e-05,0,0,3.56796e-05,0,0,2.67597e-05,0,0,2.45298e-05,0,0,1.78398e-05,0,0,8.91991e-06,0,0,2.45298e-05,0,0,5.57494e-05,0,0,1.33799e-05,0,0,2.22998e-06,0,0,1.11499e-05,0,0,2.22998e-06,0,0,1.11499e-05,0,0,1.33799e-05,0,0,6.68993e-06,0,0,8.91991e-06,0,0,1.56098e-05,0,0,1.33799e-05,0,0,1.56098e-05,0,0,2.00698e-05,0,0,2.22998e-05,0,0,2.22998e-06,0,0,8.91991e-06,0,0,2.00698e-05,0,0,1.56098e-05,0,0,1.78398e-05,0,0,8.91991e-06,0,0,1.33799e-05,0,0,8.91991e-06,0,0,1.33799e-05,0,0,8.91991e-06,0,0,8.91991e-06,0,0,8.91991e-06,0,0,8.91991e-06,0,0,2.22998e-05,0,0,8.91991e-06,0,0,1.78398e-05,0,0,8.91991e-06,0,0,1.11499e-05,0,0,8.02792e-05,0,0,8.91991e-06,0,0,1.78398e-05,0,0,1.11499e-05,0,0,1.11499e-05,0,0,1.56098e-05,0,0,2.89897e-05,0,0,1.33799e-05,0,0,2.45298e-05,0,0,1.33799e-05,0,0,6.68993e-06,0,0,4.01396e-05,0,0,2.22998e-05,0,0,0,1.78398e-05,0,0,0,3.12197e-05,0,0,0,8.91991e-06,0,0,0,6.68993e-06,0,0,0,1.11499e-05,0,0,0,4.45996e-06,0,0,0,1.11499e-05,0,0,0,8.91991e-06,0,0,0,1.33799e-05,0,0,0,4.01396e-05,0,0,0,1.78398e-05,0,0,0,1.78398e-05,0,0,0,2.00698e-05,0,0,0,1.33799e-05,0,0,0,8.91991e-06,0,0,0,1.33799e-05,0,0,0,2.22998e-05,0,0,0,2.00698e-05,0,0,0,2.22998e-05,0,0,0,1.56098e-05,0,0,0,1.33799e-05,0,0,0,2.22998e-05,0,0,0,8.91991e-06,0,0,0,1.33799e-05,0,0,0,4.90595e-05,0,0,0,2.22998e-05,0,0,0,3.34497e-05,0,0,0,5.35195e-05,0,0,0,1.11499e-05,0,0,0,2.22998e-05,0,0,0,0.000274287,0,0,0,2.45298e-05,0,0,0,3.12197e-05,0,0,0,2.89897e-05,0,0,0,1.56098e-05,0,0,0,0.000524045,0,0,0,6.68993e-06,0,0,0,8.91991e-06,0,0,0,1.78398e-05,0,0,0,8.91991e-06,0,0,0,1.78398e-05,0,0,0,6.68993e-06,0,0,0,1.33799e-05,0,0,0,1.56098e-05,0,0,0,1.33799e-05,0,0,0,6.68993e-06,0,0,0,5.35195e-05,0,0,0,8.91991e-06,0,0,0,1.78398e-05,0,0,0,1.56098e-05,0,0,0,1.11499e-05,0,0,0,1.11499e-05,0,0,0,8.91991e-06,0,0,0,1.33799e-05,0,0,0,8.91991e-06,0,0,0,2.00698e-05,0,0,0,4.45996e-06,0,0,0,2.67597e-05,0,0,0,4.45996e-06,0,0,0,1.33799e-05,0,0,0,6.68993e-05,0,0,0,1.78398e-05,0,0,0,1.56098e-05,0,0,0,1.11499e-05,0,0,0,0,1.56098e-05,0,0,0,0,2.45298e-05,0,0,0,0,1.56098e-05,0,0,0,0,2.22998e-05,0,0,0,0,1.11499e-05,0,0,0,0,1.11499e-05,0,0,0,0,2.22998e-05,0,0,0,0,8.91991e-06,0,0,0,0,1.56098e-05,0,0,0,0,3.56796e-05,0,0,0,0,2.00698e-05,0,0,0,0,4.68295e-05,0,0,0,0,2.22998e-05,0,0,0,0,2.22998e-05,0,0,0,0,1.11499e-05,0,0,0,0,8.91991e-06,0,0,0,0,2.45298e-05,0,0,0,0,2.67597e-05,0,0,0,0,2.00698e-05,0,0,0,0,3.12197e-05,0,0,0,0,2.00698e-05,0,0,0,0,2.45298e-05,0,0,0,0,1.33799e-05,0,0,0,0,1.11499e-05,0,0,0,0,2.22998e-06,0,0,0,0,4.45996e-06,0,0,0,0,8.91991e-06,0,0,0,0,1.78398e-05,0,0,0,0,8.91991e-06,0,0,0,0,6.68993e-06,0,0,0,0,6.68993e-06,0,0,0,0,1.33799e-05,0,0,0,0,8.91991e-06,0,0,0,0,2.00698e-05,0,0,0,0,4.45996e-06,0,0,0,0,6.68993e-06,0,0,0,0,1.78398e-05,0,0,0,0,1.56098e-05,0,0,0,0,1.11499e-05,0,0,0,0,8.91991e-06,0,0,0,0,8.91991e-06,0,0,0,0,1.56098e-05,0,0,0,0,8.91991e-06,0,0,0,0,1.78398e-05,0,0,0,0,1.11499e-05,0,0,0,0,2.00698e-05,0,0,0,0,1.11499e-05,0,0,0,0,2.22998e-06,0,0,0,0,1.78398e-05,0,0,0,0,1.56098e-05,0,0,0,0,2.45298e-05,0,0,0,0,0,2.00698e-05,0,0,0,0,0,6.68993e-06,0,0,0,0,0,1.56098e-05,0,0,0,0,0,4.45996e-06,0,0,0,0,0,1.56098e-05,0,0,0,0,0,1.33799e-05,0,0,0,0,0,2.00698e-05,0,0,0,0,0,4.45996e-06,0,0,0,0,0,1.33799e-05,0,0,0,0,0,8.91991e-06,0,0,0,0,0,6.68993e-06,0,0,0,0,0,2.45298e-05,0,0,0,0,0,2.67597e-05,0,0,0,0,0,2.22998e-05,0,0,0,0,0,8.91991e-06,0,0,0,0,0,1.11499e-05,0,0,0,0,0,1.33799e-05,0,0,0,0,0,2.22998e-05,0,0,0,0,0,1.78398e-05,0,0,0,0,0,1.33799e-05,0,0,0,0,0,2.22998e-05,0,0,0,0,0,2.89897e-05,0,0,0,0,0,2.67597e-05,0,0,0,0,0,6.68993e-06,0,0,0,0,0,8.91991e-06,0,0,0,0,0,1.56098e-05,0,0,0,0,0,6.68993e-06,0,0,0,0,0,6.68993e-06,0,0,0,0,0,8.91991e-06,0,0,0,0,0,4.45996e-06,0,0,0,0,0,1.78398e-05,0,0,0,0,0,6.68993e-06,0,0,0,0,0,1.11499e-05,0,0,0,0,0,1.33799e-05,0,0,0,0,0,6.68993e-06,0,0,0,0,0,8.91991e-06,0,0,0,0,0,1.33799e-05,0,0,0,0,0,1.33799e-05,0,0,0,0,0,1.56098e-05,0,0,0,0,0,2.00698e-05,0,0,0,0,0,8.91991e-06,0,0,0,0,0,6.68993e-06,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,2.22998e-05,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,2.22998e-05,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0.000111499,0,0,0,0,0,0,0,0.000209618,0,0,0,0,0,0,0,0.000283207,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,2.22998e-05,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,2.22998e-05,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,2.89897e-05,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,3.12197e-05,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,1.78398e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2.45298e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4.45996e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2.67597e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8.91991e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.11499e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6.68993e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2.22998e-06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.56098e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2.00698e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1.33799e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7.80492e-05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.00671446,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.000151638 };
