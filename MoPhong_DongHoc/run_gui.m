function run_gui()
% Mo model Simulink + scope roi chay sim (hien tren desktop song).
cd('F:/DeltaRobot/MoPhong_DongHoc');
sys = 'delta_kinematics';
load_system(sys);
open_system(sys);
open_system([sys '/Scope_theta']);
open_system([sys '/Scope_omega']);
set_param(sys,'SimulationCommand','update');
disp('>>> Dang chay mo phong Simulink...');
sim(sys);
disp('>>> Xong. Scope hien ket qua. Nhan Play de chay lai.');
end
