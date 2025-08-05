% 读取点云文件
file_path = 'D:/yunting/data/new/tree_new5.txt';
nearest_neighbors_count = 5;
point_cloud = dlmread(file_path);

% 提取坐标和 supervoxel 标识
coordinates = point_cloud(:, 1:3);
supervoxel_ids = point_cloud(:, 7);

% 找出唯一的 supervoxel 标识
unique_supervoxels = unique(point_cloud(:, 7));
num_supervoxels = numel(unique_supervoxels);

% 初始化存储每类 supervoxel 点的单元数组
supervoxel_points_cell = cell(num_supervoxels, 1);

% 将每个点按照 supervoxel 分类存储前三列信息
for i = 1:num_supervoxels
    % 找到属于当前 supervoxel 的点的索引
    indices = find(supervoxel_ids == unique_supervoxels(i));
    
    % 提取属于当前 supervoxel 的点的前三列信息
    supervoxel_points_cell{i} = point_cloud(indices, 1:3);
end

% 初始化存储所有中心点的数组
all_centroids = zeros(num_supervoxels, 3);

% 找出每个supervoxel_points_cell{i}的中心点并可视化
figure;
hold on;

% 可视化原始点云，设置为浅灰色，透明度为30%
scatter3(coordinates(:, 1), coordinates(:, 2), coordinates(:, 3), 10, [0.8, 0.8, 0.8], 'filled', 'MarkerFaceAlpha', 0.3);

for i = 1:num_supervoxels
    % 找到当前 supervoxel 的点
    supervoxel_points = supervoxel_points_cell{i};
    
    % 检查 supervoxel_points 是否为空
    if (numel(supervoxel_points) < 5)
        continue;  % 如果为空，跳过当前循环
    end
    
    % 计算当前 supervoxel 的中心点
    centroid = mean(supervoxel_points);
    
    % 将中心点存储到数组中
    all_centroids(i, :) = centroid;
end

% 删除坐标为(0,0,0)的点，并更新 supervoxels 的计数
zero_indices = find(all(all_centroids == 0, 2));
all_centroids(zero_indices, :) = [];
num_supervoxels = size(all_centroids, 1);

% 计算距离矩阵
distance_matrix = squareform(pdist(all_centroids));

% 存储最近的中心点索引和对应的距离
nearest_neighbors_indices = zeros(num_supervoxels, nearest_neighbors_count);
nearest_neighbors_distances = zeros(num_supervoxels, nearest_neighbors_count);

% 找到每个中心点的最近邻居
for i = 1:num_supervoxels
    % 获取当前中心点到其他中心点的距离
    distances_to_other_centroids = distance_matrix(i, :);
    
    % 将当前中心点排除在外，找到最近的5个中心点
    [sorted_distances, sorted_indices] = sort(distances_to_other_centroids);
    nearest_neighbors_indices(i, :) = sorted_indices(2:nearest_neighbors_count+1); % 第一个是自己
    nearest_neighbors_distances(i, :) = sorted_distances(2:nearest_neighbors_count+1); % 第一个是自己
end

% 绘制中心点
scatter3(all_centroids(:, 1), all_centroids(:, 2), all_centroids(:, 3), 'filled');

% 绘制边
for i = 1:num_supervoxels
    current_centroid = all_centroids(i, :);
    nearest_neighbor_indices = nearest_neighbors_indices(i, :);
    for j = 1:nearest_neighbors_count
        neighbor_index = nearest_neighbor_indices(j);
        neighbor_centroid = all_centroids(neighbor_index, :);
        % 绘制边
        plot3([current_centroid(1), neighbor_centroid(1)], [current_centroid(2), neighbor_centroid(2)], [current_centroid(3), neighbor_centroid(3)], 'b', 'LineWidth', 2);
    end
end

% 设置图形标题和轴标签
title('Supervoxel Centroids with Edges to Nearest Neighbors');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;
hold off;