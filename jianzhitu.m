% 文件夹名称变量
folder_name1 = 'tree_new5'; % 文件夹名

% 读取点云数据
point_cloud = load(sprintf('D:/yunting/data/new/%s.txt', folder_name1));

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

% 设置点云颜色为灰色
gray_color = [0.83, 0.83, 0.83];

% 设置透明度
alpha_value = 1;

% 读取自定义颜色条图片
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png');
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % 归一化到 [0, 1]

% 创建图形窗口
figure;
hold on;

% 绘制灰色点云
scatter3(point_cloud_X, point_cloud_Y, point_cloud_Z, 1, gray_color, 'filled', 'MarkerFaceAlpha', alpha_value);

% 绘制顶点
scatter3(X_centroids, Y_centroids, Z_centroids, 2, 'r', 'filled');

% 绘制边
max_weight = max(Weights);
for k = 1:length(Node1)
    x = [X_centroids(Node1(k)), X_centroids(Node2(k))];
    y = [Y_centroids(Node1(k)), Y_centroids(Node2(k))];
    z = [Z_centroids(Node1(k)), Z_centroids(Node2(k))];
    
    % 将权值归一化到 [0, 1]，以 max_weight 为标准，最小值强制设为 0
    normalized_weight = Weights(k) / max_weight;
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color_index = min(color_index, size(custom_cmap, 1)); % 防止越界
    color = custom_cmap(color_index, :);
    
    plot3(x, y, z, 'Color', color, 'LineWidth', 1.5);
end

% 设置轴标签和标题
xlabel('X');
ylabel('Y');
zlabel('Z');
title('点云与超体素 KNN 图可视化');

% 设置背景为白色
set(gca, 'Color', 'w');

% 关闭网格
grid off;

% 添加颜色条并强制范围从0开始
caxis([0 max_weight]);
colormap(custom_cmap);
colorbar;

% 设置坐标轴比例相等
axis equal;

hold off;
