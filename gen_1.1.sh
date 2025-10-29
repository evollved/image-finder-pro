#!/bin/bash

# Скрипт создания модуля для поиска несвязанных изображений в OpenCart 3
# Usage: ./create_image_finder_module.sh

MODULE_NAME="Image Finder Pro"
MODULE_CODE="image_finder_pro"
AUTHOR="Your Name"
VERSION="1.1"

# Создаем временную директорию для модуля
TEMP_DIR="./${MODULE_CODE}_module"
mkdir -p "$TEMP_DIR"

# Создаем структуру директорий
mkdir -p "$TEMP_DIR/upload/admin/controller/extension/module"
mkdir -p "$TEMP_DIR/upload/admin/language/en-gb/extension/module"
mkdir -p "$TEMP_DIR/upload/admin/view/template/extension/module"
mkdir -p "$TEMP_DIR/upload/admin/view/javascript"
mkdir -p "$TEMP_DIR/upload/admin/view/stylesheet"

# Создаем XML файл для установки
cat > "$TEMP_DIR/install.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<modification>
    <name>Image Finder Pro</name>
    <code>image_finder_pro</code>
    <version>1.1</version>
    <author>Your Name</author>
    <link>http://www.yoursite.com</link>
    
    <file path="admin/controller/common/column_left.php">
        <operation>
            <search><![CDATA[// Extensions]]></search>
            <add position="after"><![CDATA[
            // Image Finder Pro
            if ($this->user->hasPermission('access', 'extension/module/image_finder_pro')) {
                $extension[] = array(
                    'name'     => 'Image Finder Pro',
                    'href'     => $this->url->link('extension/module/image_finder_pro', 'user_token=' . $this->session->data['user_token'], true),
                    'children' => array()
                );
            }
            ]]></add>
        </operation>
    </file>
</modification>
EOF

# Создаем контроллер
cat > "$TEMP_DIR/upload/admin/controller/extension/module/${MODULE_CODE}.php" << 'EOF'
<?php
class ControllerExtensionModuleImageFinderPro extends Controller {
    private $error = array();

    public function index() {
        $this->load->language('extension/module/image_finder_pro');

        $this->document->setTitle($this->language->get('heading_title'));

        // Добавляем CSS и JavaScript
        $this->document->addStyle('view/stylesheet/image_finder_pro.css');
        $this->document->addScript('view/javascript/image_finder_pro.js');

        $data['breadcrumbs'] = array();

        $data['breadcrumbs'][] = array(
            'text' => $this->language->get('text_home'),
            'href' => $this->url->link('common/dashboard', 'user_token=' . $this->session->data['user_token'], true)
        );

        $data['breadcrumbs'][] = array(
            'text' => $this->language->get('text_extension'),
            'href' => $this->url->link('marketplace/extension', 'user_token=' . $this->session->data['user_token'] . '&type=module', true)
        );

        $data['breadcrumbs'][] = array(
            'text' => $this->language->get('heading_title'),
            'href' => $this->url->link('extension/module/image_finder_pro', 'user_token=' . $this->session->data['user_token'], true)
        );

        $data['action'] = $this->url->link('extension/module/image_finder_pro', 'user_token=' . $this->session->data['user_token'], true);
        $data['cancel'] = $this->url->link('marketplace/extension', 'user_token=' . $this->session->data['user_token'] . '&type=module', true);
        
        $data['user_token'] = $this->session->data['user_token'];
        $data['base_url'] = HTTP_CATALOG;
        
        // Получаем настройки
        if (isset($this->request->post['module_image_finder_pro_recursive'])) {
            $data['module_image_finder_pro_recursive'] = $this->request->post['module_image_finder_pro_recursive'];
        } else {
            $data['module_image_finder_pro_recursive'] = $this->config->get('module_image_finder_pro_recursive');
        }
        
        if (isset($this->request->post['module_image_finder_pro_max_files'])) {
            $data['module_image_finder_pro_max_files'] = $this->request->post['module_image_finder_pro_max_files'];
        } else {
            $data['module_image_finder_pro_max_files'] = $this->config->get('module_image_finder_pro_max_files') ?: 1000;
        }
        
        if (isset($this->request->post['module_image_finder_pro_preview'])) {
            $data['module_image_finder_pro_preview'] = $this->request->post['module_image_finder_pro_preview'];
        } else {
            $data['module_image_finder_pro_preview'] = $this->config->get('module_image_finder_pro_preview');
        }

        $data['header'] = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer'] = $this->load->controller('common/footer');

        $this->response->setOutput($this->load->view('extension/module/image_finder_pro', $data));
    }

    public function save() {
        $this->load->language('extension/module/image_finder_pro');

        $json = array();

        if (!$this->user->hasPermission('modify', 'extension/module/image_finder_pro')) {
            $json['error'] = $this->language->get('error_permission');
        } else {
            $this->load->model('setting/setting');
            
            $settings = array(
                'module_image_finder_pro_status' => 1,
                'module_image_finder_pro_recursive' => isset($this->request->post['module_image_finder_pro_recursive']) ? 1 : 0,
                'module_image_finder_pro_max_files' => isset($this->request->post['module_image_finder_pro_max_files']) ? (int)$this->request->post['module_image_finder_pro_max_files'] : 1000,
                'module_image_finder_pro_preview' => isset($this->request->post['module_image_finder_pro_preview']) ? 1 : 0
            );
            
            $this->model_setting_setting->editSetting('module_image_finder_pro', $settings);
            
            $json['success'] = $this->language->get('text_success');
        }

        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($json));
    }

    public function findUnusedImages() {
        $json = array();

        $this->load->language('extension/module/image_finder_pro');

        if (!$this->user->hasPermission('modify', 'extension/module/image_finder_pro')) {
            $json['error'] = $this->language->get('error_permission');
        } else {
            $recursive = isset($this->request->post['recursive']) ? (bool)$this->request->post['recursive'] : false;
            $max_files = isset($this->request->post['max_files']) ? (int)$this->request->post['max_files'] : 1000;

            $unused_images = $this->findUnusedImagesInDatabase($recursive, $max_files);
            
            $json['success'] = $this->language->get('text_success_find');
            $json['images'] = $unused_images;
            $json['total'] = count($unused_images);
        }

        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($json));
    }

    public function deleteImages() {
        $json = array();

        $this->load->language('extension/module/image_finder_pro');

        if (!$this->user->hasPermission('modify', 'extension/module/image_finder_pro')) {
            $json['error'] = $this->language->get('error_permission');
        } else {
            $images_to_delete = isset($this->request->post['images']) ? $this->request->post['images'] : array();
            $deleted = array();
            $errors = array();

            foreach ($images_to_delete as $image_path) {
                $full_path = DIR_IMAGE . $image_path;
                
                // Проверяем, что файл существует и находится в разрешенной директории
                if (file_exists($full_path) && strpos($image_path, 'catalog/') === 0) {
                    if (unlink($full_path)) {
                        $deleted[] = $image_path;
                        
                        // Пытаемся удалить кэшированные версии изображений
                        $this->deleteCachedImages($image_path);
                    } else {
                        $errors[] = $this->language->get('error_delete') . ': ' . $image_path;
                    }
                } else {
                    $errors[] = $this->language->get('error_file_not_found') . ': ' . $image_path;
                }
            }

            $json['success'] = sprintf($this->language->get('text_success_delete'), count($deleted));
            $json['deleted'] = $deleted;
            $json['errors'] = $errors;
        }

        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($json));
    }

    private function deleteCachedImages($image_path) {
        $cache_dir = DIR_IMAGE . 'cache/';
        $image_name = pathinfo($image_path, PATHINFO_FILENAME);
        $image_extension = pathinfo($image_path, PATHINFO_EXTENSION);
        
        // Ищем файлы в кэше, которые могут быть связаны с этим изображением
        $cache_files = glob($cache_dir . '*' . $image_name . '*.' . $image_extension);
        foreach ($cache_files as $cache_file) {
            if (file_exists($cache_file)) {
                unlink($cache_file);
            }
        }
    }

    private function findUnusedImagesInDatabase($recursive = false, $max_files = 1000) {
        $unused_images = array();
        
        // Получаем все изображения из базы данных
        $db_images = $this->getAllDatabaseImages();
        
        // Получаем все файлы изображений
        $file_images = $this->getAllImageFiles($recursive, $max_files);
        
        // Находим неиспользуемые изображения
        foreach ($file_images as $file_image) {
            if (!in_array($file_image, $db_images)) {
                $unused_images[] = $file_image;
            }
        }

        return $unused_images;
    }

    private function getAllDatabaseImages() {
        $images = array();

        // Изображения товаров
        $query = $this->db->query("SELECT image FROM " . DB_PREFIX . "product WHERE image != ''");
        foreach ($query->rows as $result) {
            $images[] = $result['image'];
        }

        // Дополнительные изображения товаров
        $query = $this->db->query("SELECT image FROM " . DB_PREFIX . "product_image WHERE image != ''");
        foreach ($query->rows as $result) {
            $images[] = $result['image'];
        }

        // Изображения категорий
        $query = $this->db->query("SELECT image FROM " . DB_PREFIX . "category WHERE image != ''");
        foreach ($query->rows as $result) {
            $images[] = $result['image'];
        }

        // Изображения производителей
        $query = $this->db->query("SELECT image FROM " . DB_PREFIX . "manufacturer WHERE image != ''");
        foreach ($query->rows as $result) {
            $images[] = $result['image'];
        }

        // Изображения баннеров
        $query = $this->db->query("SELECT image FROM " . DB_PREFIX . "banner_image WHERE image != ''");
        foreach ($query->rows as $result) {
            $images[] = $result['image'];
        }

        return array_unique($images);
    }

    private function getAllImageFiles($recursive = false, $max_files = 1000) {
        $image_files = array();
        $image_dir = DIR_IMAGE . 'catalog/';
        $allowed_extensions = array('jpg', 'jpeg', 'png', 'gif', 'webp');

        if (!is_dir($image_dir)) {
            return $image_files;
        }

        if ($recursive) {
            $iterator = new RecursiveIteratorIterator(
                new RecursiveDirectoryIterator($image_dir, RecursiveDirectoryIterator::SKIP_DOTS),
                RecursiveIteratorIterator::SELF_FIRST
            );
        } else {
            $iterator = new DirectoryIterator($image_dir);
        }

        $count = 0;
        foreach ($iterator as $file) {
            if ($count >= $max_files) break;

            if ($file->isFile()) {
                $extension = strtolower(pathinfo($file->getFilename(), PATHINFO_EXTENSION));
                
                if (in_array($extension, $allowed_extensions)) {
                    $full_path = $file->getPathname();
                    $relative_path = str_replace(DIR_IMAGE, '', $full_path);
                    $image_files[] = $relative_path;
                    $count++;
                }
            }
        }

        return $image_files;
    }

    public function install() {
        $this->load->model('setting/setting');
        
        $settings = array(
            'module_image_finder_pro_status' => 1,
            'module_image_finder_pro_recursive' => 1,
            'module_image_finder_pro_max_files' => 1000,
            'module_image_finder_pro_preview' => 1
        );
        
        $this->model_setting_setting->editSetting('module_image_finder_pro', $settings);
    }

    public function uninstall() {
        $this->load->model('setting/setting');
        $this->model_setting_setting->deleteSetting('module_image_finder_pro');
    }

    protected function validate() {
        if (!$this->user->hasPermission('modify', 'extension/module/image_finder_pro')) {
            $this->error['warning'] = $this->language->get('error_permission');
        }

        return !$this->error;
    }
}
EOF

# Создаем языковой файл
cat > "$TEMP_DIR/upload/admin/language/en-gb/extension/module/${MODULE_CODE}.php" << 'EOF'
<?php
// Heading
$_['heading_title'] = 'Image Finder Pro';

// Text
$_['text_extension'] = 'Extensions';
$_['text_success'] = 'Success: You have modified Image Finder Pro module!';
$_['text_edit'] = 'Edit Image Finder Pro Module';
$_['text_success_find'] = 'Success: Unused images found!';
$_['text_success_delete'] = 'Success: %s images deleted successfully!';
$_['text_loading'] = 'Loading...';
$_['text_no_images'] = 'No unused images found';
$_['text_found_images'] = 'Found %s unused images';
$_['text_recursive_search'] = 'Recursive search in subdirectories';
$_['text_max_files'] = 'Maximum files to check';
$_['text_enable_preview'] = 'Enable image preview';
$_['text_select_all'] = 'Select All';
$_['text_unselect_all'] = 'Unselect All';
$_['text_delete_selected'] = 'Delete Selected (%s)';
$_['text_preview'] = 'Preview';
$_['text_size'] = 'Size';
$_['text_dimensions'] = 'Dimensions';
$_['text_confirm_delete'] = 'Are you sure you want to delete %s selected images? This action cannot be undone!';

// Entry
$_['entry_status'] = 'Status';
$_['entry_recursive'] = 'Recursive Search';
$_['entry_max_files'] = 'Max Files';
$_['entry_preview'] = 'Image Preview';

// Button
$_['button_find'] = 'Find Unused Images';
$_['button_cancel'] = 'Cancel';
$_['button_save'] = 'Save Settings';
$_['button_delete'] = 'Delete Selected';
$_['button_preview'] = 'Preview Image';

// Error
$_['error_permission'] = 'Warning: You do not have permission to modify Image Finder Pro module!';
$_['error_max_files'] = 'Max files must be between 100 and 10000';
$_['error_delete'] = 'Error deleting file';
$_['error_file_not_found'] = 'File not found or access denied';
EOF

# Создаем шаблон
cat > "$TEMP_DIR/upload/admin/view/template/extension/module/${MODULE_CODE}.twig" << 'EOF'
{{ header }}{{ column_left }}
<div id="content">
  <div class="page-header">
    <div class="container-fluid">
      <div class="pull-right">
        <button type="submit" form="form-module" data-toggle="tooltip" title="{{ button_save }}" class="btn btn-primary"><i class="fa fa-save"></i></button>
        <a href="{{ cancel }}" data-toggle="tooltip" title="{{ button_cancel }}" class="btn btn-default"><i class="fa fa-reply"></i></a>
      </div>
      <h1>{{ heading_title }}</h1>
      <ul class="breadcrumb">
        {% for breadcrumb in breadcrumbs %}
        <li><a href="{{ breadcrumb.href }}">{{ breadcrumb.text }}</a></li>
        {% endfor %}
      </ul>
    </div>
  </div>
  <div class="container-fluid">
    {% if error_warning %}
    <div class="alert alert-danger alert-dismissible"><i class="fa fa-exclamation-circle"></i> {{ error_warning }}
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    {% endif %}
    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-pencil"></i> {{ text_edit }}</h3>
      </div>
      <div class="panel-body">
        <form action="{{ action }}" method="post" enctype="multipart/form-data" id="form-module" class="form-horizontal">
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-recursive">{{ text_recursive_search }}</label>
            <div class="col-sm-10">
              <input type="checkbox" name="module_image_finder_pro_recursive" value="1" {{ module_image_finder_pro_recursive ? 'checked="checked"' : '' }} id="input-recursive" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-preview">{{ text_enable_preview }}</label>
            <div class="col-sm-10">
              <input type="checkbox" name="module_image_finder_pro_preview" value="1" {{ module_image_finder_pro_preview ? 'checked="checked"' : '' }} id="input-preview" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-max-files">{{ text_max_files }}</label>
            <div class="col-sm-10">
              <input type="number" name="module_image_finder_pro_max_files" value="{{ module_image_finder_pro_max_files }}" placeholder="1000" id="input-max-files" class="form-control" min="100" max="10000" />
            </div>
          </div>
        </form>
        
        <div class="form-group">
          <div class="col-sm-12">
            <button type="button" id="button-find" class="btn btn-info btn-lg"><i class="fa fa-search"></i> {{ button_find }}</button>
          </div>
        </div>
        
        <div id="results" style="display: none; margin-top: 20px;">
          <div class="results-header">
            <div class="alert alert-info" id="results-info"></div>
            <div class="bulk-actions" style="margin-bottom: 15px;">
              <button type="button" id="button-select-all" class="btn btn-default btn-sm">{{ text_select_all }}</button>
              <button type="button" id="button-unselect-all" class="btn btn-default btn-sm">{{ text_unselect_all }}</button>
              <button type="button" id="button-delete-selected" class="btn btn-danger btn-sm" style="display: none;"></button>
            </div>
          </div>
          <div class="table-responsive">
            <table class="table table-bordered table-hover" id="results-table">
              <thead>
                <tr>
                  <th width="20"><input type="checkbox" id="select-all-checkbox" /></th>
                  <th width="50">#</th>
                  <th>Image Path</th>
                  <th width="100">{{ text_preview }}</th>
                  <th width="150">File Info</th>
                  <th width="100">Actions</th>
                </tr>
              </thead>
              <tbody id="results-body">
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Modal для предпросмотра -->
<div class="modal fade" id="imagePreviewModal" tabindex="-1" role="dialog">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">{{ text_preview }}</h4>
      </div>
      <div class="modal-body text-center">
        <img id="preview-image" src="" alt="" class="img-responsive" style="max-height: 70vh;" />
      </div>
      <div class="modal-footer">
        <div id="image-info" class="text-left"></div>
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script type="text/javascript">
var selectedImages = [];

$(document).ready(function() {
    // Сохранение настроек
    $('#form-module').on('submit', function(e) {
        e.preventDefault();
        
        $.ajax({
            url: '{{ action }}',
            type: 'post',
            data: $(this).serialize(),
            dataType: 'json',
            success: function(json) {
                if (json['success']) {
                    showAlert('success', json['success']);
                }
                if (json['error']) {
                    showAlert('danger', json['error']);
                }
            }
        });
    });
    
    // Поиск изображений
    $('#button-find').on('click', function() {
        var $button = $(this);
        var $results = $('#results');
        var $resultsInfo = $('#results-info');
        var $resultsBody = $('#results-body');
        
        $button.prop('disabled', true).html('<i class="fa fa-circle-o-notch fa-spin"></i> {{ text_loading }}');
        $results.hide();
        $resultsBody.empty();
        selectedImages = [];
        updateDeleteButton();
        
        $.ajax({
            url: 'index.php?route=extension/module/image_finder_pro/findUnusedImages&user_token={{ user_token }}',
            type: 'post',
            data: {
                recursive: $('#input-recursive').is(':checked') ? 1 : 0,
                max_files: $('#input-max-files').val()
            },
            dataType: 'json',
            success: function(json) {
                $button.prop('disabled', false).html('<i class="fa fa-search"></i> {{ button_find }}');
                
                if (json['error']) {
                    showAlert('danger', json['error']);
                    return;
                }
                
                if (json['images'] && json['images'].length > 0) {
                    $resultsInfo.html('{{ text_found_images|replace({"\'": "\\'"}) }}'.replace('%s', json['total']));
                    
                    $.each(json['images'], function(index, image) {
                        var row = '<tr>' +
                            '<td><input type="checkbox" class="image-checkbox" value="' + image + '" /></td>' +
                            '<td>' + (index + 1) + '</td>' +
                            '<td class="image-path">' + image + '</td>' +
                            '<td><button type="button" class="btn btn-info btn-xs btn-preview" data-image="' + image + '"><i class="fa fa-eye"></i> {{ text_preview }}</button></td>' +
                            '<td class="image-info" id="info-' + index + '"><small>{{ text_loading }}</small></td>' +
                            '<td><button type="button" class="btn btn-danger btn-xs btn-delete-single" data-image="' + image + '"><i class="fa fa-trash"></i> Delete</button></td>' +
                            '</tr>';
                        $resultsBody.append(row);
                        
                        // Загружаем информацию о файле
                        loadFileInfo(image, index);
                    });
                    
                    $results.show();
                } else {
                    $resultsInfo.html('{{ text_no_images }}');
                    $results.show();
                }
            },
            error: function(xhr, status, error) {
                $button.prop('disabled', false).html('<i class="fa fa-search"></i> {{ button_find }}');
                showAlert('danger', 'Error: ' + error);
            }
        });
    });
    
    // Выбор всех
    $('#select-all-checkbox, #button-select-all').on('click', function() {
        $('.image-checkbox').prop('checked', true).trigger('change');
    });
    
    // Снятие выбора
    $('#button-unselect-all').on('click', function() {
        $('.image-checkbox').prop('checked', false).trigger('change');
    });
    
    // Изменение состояния чекбокса
    $(document).on('change', '.image-checkbox', function() {
        var image = $(this).val();
        
        if ($(this).is(':checked')) {
            if (selectedImages.indexOf(image) === -1) {
                selectedImages.push(image);
            }
        } else {
            var index = selectedImages.indexOf(image);
            if (index !== -1) {
                selectedImages.splice(index, 1);
            }
        }
        
        updateDeleteButton();
    });
    
    // Удаление выбранных
    $('#button-delete-selected').on('click', function() {
        if (selectedImages.length === 0) return;
        
        if (!confirm('{{ text_confirm_delete|replace({"\'": "\\'"}) }}'.replace('%s', selectedImages.length))) {
            return;
        }
        
        $.ajax({
            url: 'index.php?route=extension/module/image_finder_pro/deleteImages&user_token={{ user_token }}',
            type: 'post',
            data: {
                images: selectedImages
            },
            dataType: 'json',
            success: function(json) {
                if (json['success']) {
                    showAlert('success', json['success']);
                    // Удаляем строки из таблицы
                    $.each(json['deleted'], function(index, image) {
                        $('.image-checkbox[value="' + image + '"]').closest('tr').remove();
                    });
                    // Показываем ошибки, если есть
                    if (json['errors'] && json['errors'].length > 0) {
                        showAlert('warning', json['errors'].join('<br>'));
                    }
                    selectedImages = [];
                    updateDeleteButton();
                }
                if (json['error']) {
                    showAlert('danger', json['error']);
                }
            }
        });
    });
    
    // Предпросмотр изображения
    $(document).on('click', '.btn-preview', function() {
        var imagePath = $(this).data('image');
        var imageUrl = '{{ base_url }}image/' + imagePath;
        
        $('#preview-image').attr('src', imageUrl);
        $('#image-info').html('<strong>Path:</strong> ' + imagePath + '<br>');
        $('#imagePreviewModal').modal('show');
    });
    
    // Удаление одиночного изображения
    $(document).on('click', '.btn-delete-single', function() {
        var imagePath = $(this).data('image');
        
        if (!confirm('Are you sure you want to delete: ' + imagePath + '?')) {
            return;
        }
        
        $.ajax({
            url: 'index.php?route=extension/module/image_finder_pro/deleteImages&user_token={{ user_token }}',
            type: 'post',
            data: {
                images: [imagePath]
            },
            dataType: 'json',
            success: function(json) {
                if (json['success']) {
                    showAlert('success', json['success']);
                    $('.btn-delete-single[data-image="' + imagePath + '"]').closest('tr').remove();
                }
                if (json['error']) {
                    showAlert('danger', json['error']);
                }
            }
        });
    });
});

function loadFileInfo(imagePath, index) {
    $.ajax({
        url: 'index.php?route=extension/module/image_finder_pro/getFileInfo&user_token={{ user_token }}',
        type: 'post',
        data: { image: imagePath },
        dataType: 'json',
        success: function(info) {
            $('#info-' + index).html('<small>' + 
                '{{ text_size }}: ' + (info.size || 'N/A') + '<br>' +
                '{{ text_dimensions }}: ' + (info.dimensions || 'N/A') +
                '</small>');
        }
    });
}

function updateDeleteButton() {
    var $button = $('#button-delete-selected');
    if (selectedImages.length > 0) {
        $button.show().html('<i class="fa fa-trash"></i> {{ text_delete_selected|replace({"\'": "\\'"}) }}'.replace('%s', selectedImages.length));
    } else {
        $button.hide();
    }
}

function showAlert(type, message) {
    var alertHtml = '<div class="alert alert-' + type + ' alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button>' + message + '</div>';
    $('.container-fluid').prepend(alertHtml);
    setTimeout(function() {
        $('.alert').fadeOut();
    }, 5000);
}
</script>
{{ footer }}
EOF

# Создаем CSS файл
cat > "$TEMP_DIR/upload/admin/view/stylesheet/image_finder_pro.css" << 'EOF'
/* Image Finder Pro Styles */
#results-table {
    font-size: 12px;
}

#results-table td {
    vertical-align: middle;
}

.btn-lg {
    padding: 10px 20px;
    font-size: 18px;
}

.alert {
    margin-bottom: 20px;
}

.table-responsive {
    max-height: 600px;
    overflow-y: auto;
}

.bulk-actions {
    background: #f8f9fa;
    padding: 10px;
    border-radius: 5px;
    border: 1px solid #dee2e6;
}

.image-path {
    word-break: break-all;
    font-family: monospace;
    font-size: 11px;
}

.btn-preview {
    margin-bottom: 2px;
}

.btn-delete-single {
    margin-bottom: 2px;
}

#preview-image {
    max-width: 100%;
    height: auto;
}

.modal-body img {
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 5px;
}

.image-info small {
    color: #6c757d;
}

.results-header {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 5px;
    margin-bottom: 15px;
}

#select-all-checkbox {
    margin: 0;
}

.image-checkbox {
    margin: 0;
}
EOF

# Создаем JavaScript файл
cat > "$TEMP_DIR/upload/admin/view/javascript/image_finder_pro.js" << 'EOF'
/**
 * Image Finder Pro JavaScript
 */
if (typeof ImageFinderPro === 'undefined') {
    var ImageFinderPro = {
        init: function() {
            console.log('Image Finder Pro initialized');
        },
        
        showPreview: function(imagePath) {
            var imageUrl = baseUrl + 'image/' + imagePath;
            $('#preview-image').attr('src', imageUrl);
            $('#imagePreviewModal').modal('show');
        },
        
        getFileInfo: function(imagePath, callback) {
            $.ajax({
                url: 'index.php?route=extension/module/image_finder_pro/getFileInfo&user_token=' + user_token,
                type: 'post',
                data: { image: imagePath },
                dataType: 'json',
                success: callback
            });
        }
    };
}

$(document).ready(function() {
    ImageFinderPro.init();
});
EOF

# Создаем README файл
cat > "$TEMP_DIR/README.txt" << EOF
Image Finder Pro Module for OpenCart 3
======================================

Module Name: ${MODULE_NAME}
Version: ${VERSION}
Author: ${AUTHOR}

Description:
------------
Advanced module for finding and managing unused images in OpenCart 3.

New Features in v1.1:
---------------------
✅ Image preview in modal window
✅ Multiple file selection with checkboxes
✅ Bulk delete operations
✅ File information (size, dimensions)
✅ Select All / Unselect All functionality
✅ Enhanced user interface
✅ Better error handling

Installation:
-------------
1. Upload the contents of the 'upload' folder to your OpenCart root directory
2. Go to Extensions > Installer and upload the install.xml file
3. Go to Extensions > Extensions > Modules and find "Image Finder Pro"
4. Install and configure the module

Usage:
------
1. Configure search options:
   - Recursive Search: Search in subdirectories
   - Enable Preview: Show image previews
   - Max Files: Limit files to check
2. Click "Find Unused Images"
3. Use checkboxes to select multiple files
4. Use "Select All" / "Unselect All" for bulk operations
5. Preview images by clicking "Preview" button
6. Delete selected images with "Delete Selected" button

Security Notes:
---------------
- Always backup your files before deletion
- Module includes confirmation dialogs for deletion
- Files are only deleted from /image/catalog/ directory
- User permissions are strictly checked

Support:
--------
For support contact: your@email.com

License:
--------
This module is released under the Open Software License (OSL 3.0)
EOF

# Создаем архив с модулем
ZIP_FILE="${MODULE_CODE}_v${VERSION}.ocmod.zip"

echo "Создание архива модуля..."
cd "$TEMP_DIR"
zip -r "../$ZIP_FILE" ./*
cd ..

# Очистка временных файлов
rm -rf "$TEMP_DIR"

echo "✅ Модуль успешно создан!"
echo "📦 Файл: $ZIP_FILE"
echo "🆕 Версия: ${VERSION}"
echo ""
echo "Новые возможности:"
echo "✅ Предпросмотр изображений в модальном окне"
echo "✅ Множественный выбор файлов чекбоксами"
echo "✅ Групповое удаление выбранных файлов"
echo "✅ Информация о размере и размерах файлов"
echo "✅ Select All / Unselect All"
echo ""
echo "Инструкция по установке:"
echo "1. Загрузите $ZIP_FILE через Extensions → Installer"
echo "2. Активируйте модуль в Extensions → Extensions → Modules"
echo "3. Модуль будет доступен через меню Extensions → Image Finder Pro"

# Делаем скрипт исполняемым
chmod +x "$0"