% 文件夹名称变量
folder_name1 = '补充'; % 文件夹名

% 读取点云数据
point_cloud = load(sprintf('D:/yunting/data/bigpicture/%s.txt', folder_name1));

% 提取点云坐标和类别标签
point_cloud_X = point_cloud(:, 1);
point_cloud_Y = point_cloud(:, 2);
point_cloud_Z = point_cloud(:, 3);
labels = point_cloud(:, 8); % 第八列为类别标签

% 读取顶点和边信息
centroids_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_centroids.csv', folder_name1));
edges_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_edges_weights.csv', folder_name1));

% 提取顶点坐标
X_centroids = centroids_data.X;
Y_centroids = centroids_data.Y;
Z_centroids = centroids_data.Z;

% 提取边信息
Node1 = edges_data.Node1 + 1; % MATLAB 索引从1开始
Node2 = edges_data.Node2 + 1;
Weights = edges_data.Weight;

% 定义类别标签、对应颜色和透明度
label_colors = [
    0, 0.78, 0.63, 0.78, 0.7;  % 淡紫色
    1, 0.5, 0.5, 0.5, 0.8;            % 蓝色
    2, 0, 0, 1, 0.4;    % 荧光浅蓝色
    3, 0, 1, 0, 0.4;            % 绿色
    4, 1, 1, 0, 0.5;            % 黄色
    5, 0.6, 0.3, 0.1, 0.4;      % 荧光浅绿色
    6, 1, 0.75, 0.8, 0.5;       % 粉色
    7, 1, 0.5, 0, 0.6;          % 橙色
    8, 1, 0, 0, 0.3;            % 红色
];

% 设置不同类别的稀疏度
sparsity_map = containers.Map(0:8, [1, 0.5, 1, 1, 1, 1, 1, 1, 0.5]);

% 读取自定义颜色条图片
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png');
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % 归一化到 [0, 1]

% 创建图形窗口
figure;
hold on;

% 按标签分类处理点云
for i = 1:size(label_colors, 1)
    current_label = label_colors(i, 1);
    color = label_colors(i, 2:4);
    alpha_value = label_colors(i, 5);
    
    % 提取当前标签的点云
    label_indices = (labels == current_label);
    current_points_X = point_cloud_X(label_indices);
    current_points_Y = point_cloud_Y(label_indices);
    current_points_Z = point_cloud_Z(label_indices);
    
    % 计算稀疏度
    sparsity = sparsity_map(current_label);
    num_points = sum(label_indices);
    sample_indices = randperm(num_points, round(sparsity * num_points));
    current_points_X = current_points_X(sample_indices);
    current_points_Y = current_points_Y(sample_indices);
    current_points_Z = current_points_Z(sample_indices);
    
    % 绘制点云
    scatter3(current_points_X, current_points_Y, current_points_Z, 1, color, 'filled', 'MarkerFaceAlpha', alpha_value);
end

% 绘制顶点
scatter3(X_centroids, Y_centroids, Z_centroids, 2, 'r', 'filled');

% 绘制边
min_weight = min(Weights);
max_weight = max(Weights);
for k = 1:length(Node1)
    x = [X_centroids(Node1(k)), X_centroids(Node2(k))];
    y = [Y_centroids(Node1(k)), Y_centroids(Node2(k))];
    z = [Z_centroids(Node1(k)), Z_centroids(Node2(k))];
    
    normalized_weight = (Weights(k) - min_weight) / (max_weight - min_weight);
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color = custom_cmap(color_index, :);
    
    plot3(x, y, z, 'Color', color, 'LineWidth', 0.9);
end

% 设置轴标签和标题
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Point Cloud and Supervoxel KNN Graph Visualization');

% 设置背景为白色
set(gca, 'Color', 'w');

% 关闭网格
grid off;

% 添加颜色条
caxis([min_weight max_weight]);
colormap(custom_cmap);
colorbar;

% 设置坐标轴比例相等
% axis equal;

hold off;
