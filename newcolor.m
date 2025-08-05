% 设定文件夹名称变量
folder_name = 'L002_class3';

% 读取顶点和边的信息
centroids_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_centroids.csv', folder_name));
edges_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_edges_weights.csv', folder_name));

% 提取顶点坐标
X = centroids_data.X;
Y = centroids_data.Y;
Z = centroids_data.Z;

% 提取边的信息
Node1 = edges_data.Node1 + 1; % MATLAB 索引从1开始
Node2 = edges_data.Node2 + 1;
Weights = edges_data.Weight;

% 读取点云数据
point_cloud = load(sprintf('D:/yunting/data/bigpicture/%s.txt', folder_name));
point_cloud_X = point_cloud(:, 1);
point_cloud_Y = point_cloud(:, 2);
point_cloud_Z = point_cloud(:, 3);

% 随机抽稀点云数据，保留30%
num_points = size(point_cloud, 1);
sample_indices = randperm(num_points, round(0.3 * num_points)); % 随机选择30%的点
point_cloud_X = point_cloud_X(sample_indices);
point_cloud_Y = point_cloud_Y(sample_indices);
point_cloud_Z = point_cloud_Z(sample_indices);

% 读取自定义颜色条图片
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png'); % 假设图片格式为 PNG

% 将颜色条图片转换为 colormap
% 假设图片是水平的颜色条
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % 归一化到 [0, 1]

% 绘制点云数据
figure;
scatter3(point_cloud_X, point_cloud_Y, point_cloud_Z, 2, [0.8, 0.8, 0.8], 'filled', 'MarkerFaceAlpha', 0.3); % 浅灰色，20%透明度
hold on;

% 绘制顶点
scatter3(X, Y, Z, 2, 'r', 'filled');

% 获取权值的最小值和最大值
min_weight = min(Weights);
max_weight = max(Weights);

% 绘制边
for k = 1:length(Node1)
    % 获取边的两个顶点坐标
    x = [X(Node1(k)), X(Node2(k))];
    y = [Y(Node1(k)), Y(Node2(k))];
    z = [Z(Node1(k)), Z(Node2(k))];
    
    % 归一化权值到[0, 1]范围
    normalized_weight = (Weights(k) - min_weight) / (max_weight - min_weight);
    
    % 根据权值选择颜色
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color = custom_cmap(color_index, :);
    
    % 绘制边
    plot3(x, y, z, 'Color', color, 'LineWidth', 0.5);
end

% 设置轴标签和标题
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Supervoxel KNN Graph Visualization');

% 设置背景为白色
set(gca, 'Color', 'w');

% 关闭网格
grid off;

% 添加颜色条
caxis([min_weight max_weight]); % 设置颜色条的范围
colormap(custom_cmap); % 使用自定义颜色映射
colorbar; % 显示颜色条

% 设置坐标轴比例相等
axis equal; % 确保各轴的比例相同

hold off;
