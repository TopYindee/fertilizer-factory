<template>
  <div class="min-h-screen flex flex-col bg-gray-50">
    <!-- Supabase Config Modal if not set -->
    <div v-if="!isConfigured" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-xl shadow-2xl max-w-md w-full p-6 space-y-4">
        <div class="text-center">
          <div class="w-12 h-12 bg-burgundy-100 text-burgundy-600 rounded-full flex items-center justify-center mx-auto mb-2 text-xl">
            <i class="fa-solid fa-database"></i>
          </div>
          <h2 class="text-xl font-bold text-gray-900">ตั้งค่าการเชื่อมต่อ Supabase</h2>
          <p class="text-sm text-gray-500 mt-1">กรุณากรอก Supabase URL และ Anon Key เพื่อเริ่มใช้งานระบบ</p>
        </div>
        <div class="space-y-3">
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1">Supabase URL</label>
            <input v-model="tempUrl" type="text" placeholder="https://xxxx.supabase.co" class="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1">Supabase Anon Key</label>
            <input v-model="tempKey" type="password" placeholder="eyJhbGciOi..." class="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
          </div>
          <button @click="saveConfig" class="w-full bg-burgundy-600 hover:bg-burgundy-700 text-white font-medium py-2 rounded-lg text-sm transition shadow">
            เชื่อมต่อฐานข้อมูล
          </button>
        </div>
      </div>
    </div>

    <!-- Login View -->
    <div v-else-if="!isLoggedIn" class="min-h-screen flex items-center justify-center p-4 bg-burgundy-900">
      <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 sm:p-8 space-y-6">
        <div class="text-center space-y-2">
          <div class="w-16 h-16 bg-burgundy-100 text-burgundy-600 rounded-2xl flex items-center justify-center mx-auto text-2xl shadow-inner">
            <i class="fa-solid fa-industry"></i>
          </div>
          <h2 class="text-xl sm:text-2xl font-bold text-gray-900">ระบบบริหารจัดการโรงปุ๋ย</h2>
          <p class="text-xs text-gray-500">กรุณาเข้าสู่ระบบด้วยบัญชีพนักงานของคุณ</p>
        </div>
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1">ชื่อผู้ใช้งาน (Username)</label>
            <input v-model="loginForm.username" type="text" placeholder="เช่น admin" required class="w-full px-3.5 py-2.5 border rounded-xl text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1">รหัสผ่าน (Password)</label>
            <input v-model="loginForm.password" type="password" placeholder="••••••" required class="w-full px-3.5 py-2.5 border rounded-xl text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
          </div>
          <button type="submit" :disabled="loginLoading" class="w-full bg-burgundy-600 hover:bg-burgundy-700 text-white font-medium py-3 rounded-xl text-sm transition shadow-lg shadow-burgundy-600/30 flex items-center justify-center space-x-2">
            <i v-if="loginLoading" class="fa-solid fa-spinner fa-spin"></i>
            <span>{{ loginLoading ? 'กำลังตรวจสอบ...' : 'เข้าสู่ระบบ' }}</span>
          </button>
          <div class="text-center pt-2">
            <p class="text-[11px] text-gray-400">บัญชีทดสอบเริ่มต้น: Username: <b>admin</b> | Password: <b>123456</b></p>
          </div>
        </form>
      </div>
    </div>

    <!-- Main Layout -->
    <div v-else class="flex h-screen overflow-hidden relative">
      <!-- Mobile Sidebar Backdrop -->
      <div v-if="sidebarOpen" @click="sidebarOpen = false" class="fixed inset-0 bg-black/50 z-30 md:hidden"></div>

      <!-- Sidebar -->
      <aside :class="{'translate-x-0': sidebarOpen, '-translate-x-full': !sidebarOpen}" class="fixed md:static inset-y-0 left-0 w-64 bg-burgundy-800 text-white flex flex-col shadow-xl z-40 transform transition-transform duration-200 ease-in-out md:translate-x-0">
        <div class="p-4 border-b border-burgundy-700 flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <div class="bg-burgundy-600 p-2 rounded-lg text-white">
              <i class="fa-solid fa-industry text-lg"></i>
            </div>
            <div>
              <h1 class="font-bold text-base leading-tight">โรงปุ๋ยเทพ & เวิลด์</h1>
              <p class="text-xs text-burgundy-100/70">Role: {{ currentUser.role }}</p>
            </div>
          </div>
          <button @click="sidebarOpen = false" class="md:hidden text-burgundy-100 hover:text-white p-1">
            <i class="fa-solid fa-xmark text-lg"></i>
          </button>
        </div>

        <nav class="flex-1 overflow-y-auto p-3 space-y-1">
          <button @click="currentTab = 'dashboard'; sidebarOpen = false" :class="{'bg-burgundy-600 text-white': currentTab === 'dashboard', 'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== 'dashboard'}" class="w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition">
            <i class="fa-solid fa-chart-pie w-5 text-center"></i>
            <span>แดชบอร์ด & ภาพรวม</span>
          </button>

          <div class="pt-3 pb-1 px-3 text-[10px] uppercase tracking-wider text-burgundy-100/50 font-semibold">ข้อมูลหลัก (Master Data)</div>

          <button v-for="tab in tabs" :key="tab.id" @click="currentTab = tab.id; sidebarOpen = false" :class="{'bg-burgundy-600 text-white': currentTab === tab.id, 'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== tab.id}" class="w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition">
            <i :class="tab.icon" class="w-5 text-center"></i>
            <span class="truncate">{{ tab.name }}</span>
          </button>

          <button @click="currentTab = 'reports'; sidebarOpen = false" :class="{'bg-burgundy-600 text-white': currentTab === 'reports', 'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== 'reports'}" class="w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition mt-2">
            <i class="fa-solid fa-file-excel w-5 text-center"></i>
            <span>รายงานทั้งหมด</span>
          </button>
        </nav>

        <div class="p-3 border-t border-burgundy-700 text-xs flex items-center justify-between text-burgundy-100/70">
          <div class="truncate pr-2">
            <i class="fa-solid fa-user-circle mr-1"></i> {{ currentUser.full_name }}
          </div>
          <button @click="handleLogout" title="ออกจากระบบ" class="hover:text-white text-red-300"><i class="fa-solid fa-right-from-bracket"></i></button>
        </div>
      </aside>

      <!-- Content Area -->
      <main class="flex-1 flex flex-col overflow-hidden bg-gray-100 w-full">
        <!-- Top Navbar -->
        <header class="bg-white border-b h-14 flex items-center justify-between px-4 sm:px-6 shadow-sm shrink-0">
          <div class="flex items-center space-x-3">
            <button @click="sidebarOpen = true" class="md:hidden text-gray-600 hover:text-gray-900 p-1.5 focus:outline-none">
              <i class="fa-solid fa-bars text-lg"></i>
            </button>
            <h2 class="text-base sm:text-lg font-bold text-gray-800 truncate">{{ currentTitle }}</h2>
          </div>
          <div class="flex items-center space-x-3">
            <span class="text-[11px] sm:text-xs bg-emerald-100 text-emerald-800 px-2.5 py-1 rounded-full font-medium"><i class="fa-solid fa-circle text-[8px] mr-1 text-emerald-500"></i> Online DB</span>
          </div>
        </header>

        <!-- Dynamic View -->
        <div class="flex-1 overflow-y-auto p-4 sm:p-6">
          <!-- Dashboard View -->
          <div v-if="currentTab === 'dashboard'" class="space-y-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4">
                <div class="w-12 h-12 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center text-xl shrink-0"><i class="fa-solid fa-truck-field"></i></div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">เจ้าหนี้ทั้งหมด</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.vendors }}</h3>
                </div>
              </div>
              <div class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4">
                <div class="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-lg flex items-center justify-center text-xl shrink-0"><i class="fa-solid fa-users"></i></div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">ลูกค้าทั้งหมด</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.customers }}</h3>
                </div>
              </div>
              <div class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4">
                <div class="w-12 h-12 bg-amber-50 text-amber-600 rounded-lg flex items-center justify-center text-xl shrink-0"><i class="fa-solid fa-cubes"></i></div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">รหัสแม่ปุ๋ย</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.raw_materials }}</h3>
                </div>
              </div>
              <div class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4">
                <div class="w-12 h-12 bg-purple-50 text-purple-600 rounded-lg flex items-center justify-center text-xl shrink-0"><i class="fa-solid fa-box"></i></div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">สินค้าสำเร็จรูป (FG)</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.products }}</h3>
                </div>
              </div>
            </div>

            <div class="bg-white p-6 rounded-xl shadow-sm border">
              <h3 class="text-base font-bold text-gray-800 mb-4">ยินดีต้อนรับ, {{ currentUser.full_name }} สู่ระบบบริหารจัดการโรงปุ๋ย</h3>
              <p class="text-sm text-gray-600 leading-relaxed">
                ระบบจัดการฐานข้อมูลและบริหารงานโรงปุ๋ยรองรับการใช้งานบนทุกอุปกรณ์ (Mobile, Tablet, Desktop) 
                เลือกเมนูด้านซ้ายเพื่อเริ่มต้นจัดการข้อมูลหรือดูรายงานได้ทันที
              </p>
            </div>
          </div>

          <!-- Reports View -->
          <div v-else-if="currentTab === 'reports'" class="space-y-6">
            <div class="bg-white p-6 rounded-xl shadow-sm border">
              <h3 class="text-base font-bold text-gray-800 mb-4">ศูนย์รวมรายงานข้อมูลโรงปุ๋ย</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div v-for="tab in tabs" :key="tab.id" class="border p-4 rounded-lg flex items-center justify-between hover:bg-gray-50 transition">
                  <div>
                    <h4 class="font-bold text-sm text-gray-800"><i :class="tab.icon" class="mr-2 text-burgundy-600"></i>{{ tab.name }}</h4>
                    <p class="text-xs text-gray-500 mt-1">จำนวนข้อมูลทั้งหมด: {{ counts[tab.id] || 0 }} รายการ</p>
                  </div>
                  <button @click="currentTab = tab.id" class="bg-burgundy-50 text-burgundy-600 hover:bg-burgundy-600 hover:text-white px-3 py-1.5 rounded-lg text-xs font-medium transition shrink-0 ml-2">
                    ดูข้อมูล
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- CRUD Table View -->
          <div v-else class="space-y-4">
            <!-- Action Bar -->
            <div class="bg-white p-4 rounded-xl shadow-sm border flex flex-col sm:flex-row items-center justify-between gap-3">
              <div class="w-full sm:w-72 relative">
                <i class="fa-solid fa-search absolute left-3 top-3 text-gray-400 text-xs"></i>
                <input v-model="searchQuery" type="text" placeholder="ค้นหาข้อมูล..." class="w-full pl-9 pr-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
              </div>
              <button @click="openModal()" class="w-full sm:w-auto bg-burgundy-600 hover:bg-burgundy-700 text-white px-4 py-2 rounded-lg text-xs font-medium flex items-center justify-center space-x-2 transition shadow">
                <i class="fa-solid fa-plus"></i>
                <span>เพิ่ม{{ currentTabObj.name }}</span>
              </button>
            </div>

            <!-- Data Table -->
            <div class="bg-white rounded-xl shadow-sm border overflow-hidden">
              <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-xs">
                  <thead>
                    <tr class="bg-gray-50 border-b text-gray-600 uppercase font-semibold">
                      <th class="p-3 whitespace-nowrap">ID / รหัส</th>
                      <th v-for="col in currentTabObj.columns" :key="col.key" class="p-3 whitespace-nowrap">{{ col.label }}</th>
                      <th class="p-3 text-center whitespace-nowrap">จัดการ</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-100">
                    <tr v-if="loading" class="text-center">
                      <td :colspan="currentTabObj.columns.length + 2" class="p-8 text-gray-400">กำลังโหลดข้อมูล...</td>
                    </tr>
                    <tr v-else-if="filteredItems.length === 0" class="text-center">
                      <td :colspan="currentTabObj.columns.length + 2" class="p-8 text-gray-400">ไม่พบข้อมูล</td>
                    </tr>
                    <tr v-for="item in filteredItems" :key="item.id" class="hover:bg-gray-50/80 transition">
                      <td class="p-3 font-medium text-gray-900 whitespace-nowrap">{{ item.code_id || item.id }}</td>
                      <td v-for="col in currentTabObj.columns" :key="col.key" class="p-3 text-gray-600">
                        {{ item[col.key] !== undefined && item[col.key] !== null ? item[col.key] : '-' }}
                      </td>
                      <td class="p-3 text-center space-x-2 whitespace-nowrap">
                        <button @click="openModal(item)" class="text-blue-600 hover:text-blue-800 p-1" title="แก้ไข"><i class="fa-solid fa-pen-to-square"></i></button>
                        <button @click="deleteItem(item.id)" class="text-red-600 hover:text-red-800 p-1" title="ลบ"><i class="fa-solid fa-trash"></i></button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- Add/Edit Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div class="bg-white rounded-xl shadow-2xl max-w-lg w-full max-h-[90vh] flex flex-col my-auto">
        <div class="p-4 border-b flex items-center justify-between shrink-0">
          <h3 class="font-bold text-gray-800 text-sm">{{ isEditing ? 'แก้ไข' : 'เพิ่ม' }}{{ currentTabObj.name }}</h3>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark text-lg"></i></button>
        </div>
        <div class="p-6 overflow-y-auto space-y-4 flex-1">
          <div v-for="field in currentTabObj.fields" :key="field.key">
            <label class="block text-xs font-semibold text-gray-700 mb-1">{{ field.label }}</label>
            <input v-if="field.type === 'text' || field.type === 'number' || field.type === 'password'" :type="field.type" v-model="formData[field.key]" class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
            <textarea v-else-if="field.type === 'textarea'" v-model="formData[field.key]" rows="3" class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"></textarea>
            <select v-else-if="field.type === 'select'" v-model="formData[field.key]" class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none">
              <option v-for="opt in field.options" :key="opt" :value="opt">{{ opt }}</option>
            </select>
          </div>
        </div>
        <div class="p-4 border-t bg-gray-50 flex justify-end space-x-2 shrink-0">
          <button @click="closeModal" class="px-4 py-2 border rounded-lg text-xs font-medium text-gray-600 hover:bg-gray-100">ยกเลิก</button>
          <button @click="saveItem" class="px-4 py-2 bg-burgundy-600 hover:bg-burgundy-700 text-white rounded-lg text-xs font-medium shadow">บันทึก</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { createClient } from '@supabase/supabase-js'
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './supabaseConfig.js'

export default {
  name: 'App',
  data() {
    const supabaseUrl = SUPABASE_URL || localStorage.getItem('sb_url') || ''
    const supabaseKey = (SUPABASE_ANON_KEY !== 'วาง_Anon_Key_ของคุณที่นี่' ? SUPABASE_ANON_KEY : '') || localStorage.getItem('sb_key') || ''
    const savedUser = JSON.parse(localStorage.getItem('current_user') || 'null')

    return {
      sidebarOpen: false,
      supabaseUrl,
      supabaseKey,
      isConfigured: !!supabaseUrl && !!supabaseKey,
      tempUrl: supabaseUrl,
      tempKey: supabaseKey,
      supabaseClient: (supabaseUrl && supabaseKey) ? createClient(supabaseUrl, supabaseKey) : null,
      
      isLoggedIn: !!savedUser,
      currentUser: savedUser || {},
      loginForm: { username: '', password: '' },
      loginLoading: false,

      currentTab: 'dashboard',
      searchQuery: '',
      loading: false,
      items: [],
      showModal: false,
      isEditing: false,
      editingId: null,
      formData: {},
      counts: { vendors: 0, customers: 0, raw_materials: 0, products: 0, packaging: 0, companies: 0, crop_years: 0, warehouses: 0, employees: 0 },
      tabs: [
        {
          id: 'companies',
          name: 'ข้อมูลบริษัท',
          icon: 'fa-solid fa-building',
          table: 'companies',
          columns: [
            { key: 'thai_name', label: 'ชื่อไทย' },
            { key: 'branch', label: 'สาขา' },
            { key: 'tax_id', label: 'เลขผู้เสียภาษี' }
          ],
          fields: [
            { key: 'thai_name', label: 'ชื่อไทย', type: 'text' },
            { key: 'eng_name', label: 'ชื่ออังกฤษ', type: 'text' },
            { key: 'branch', label: 'สาขา', type: 'text' },
            { key: 'tax_id', label: 'เลขผู้เสียภาษี', type: 'text' },
            { key: 'address', label: 'ที่อยู่', type: 'textarea' }
          ]
        },
        {
          id: 'crop_years',
          name: 'ปีการผลิต',
          icon: 'fa-solid fa-calendar-days',
          table: 'crop_years',
          columns: [
            { key: 'year_code', label: 'รหัสปี' },
            { key: 'start_date', label: 'วันเริ่ม' },
            { key: 'end_date', label: 'วันจบ' },
            { key: 'status', label: 'สถานะ' }
          ],
          fields: [
            { key: 'year_code', label: 'รหัสปี', type: 'text' },
            { key: 'start_date', label: 'วันเริ่ม', type: 'text' },
            { key: 'end_date', label: 'วันจบ', type: 'text' },
            { key: 'status', label: 'สถานะ', type: 'select', options: ['เปิด', 'ปิด'] }
          ]
        },
        {
          id: 'warehouses',
          name: 'ตั้งค่าโกดัง',
          icon: 'fa-solid fa-warehouse',
          table: 'warehouses',
          columns: [
            { key: 'warehouse_type', label: 'ประเภทโกดัง' },
            { key: 'main_code', label: 'รหัสโกดังหลัก' },
            { key: 'sub_zone', label: 'โซนย่อย' },
            { key: 'capacity', label: 'ความจุ' }
          ],
          fields: [
            { key: 'warehouse_type', label: 'ประเภทโกดัง', type: 'text' },
            { key: 'main_code', label: 'รหัสโกดังหลัก', type: 'text' },
            { key: 'sub_zone', label: 'โซนย่อย', type: 'text' },
            { key: 'capacity', label: 'ปริมาณจัดเก็บ', type: 'number' },
            { key: 'unit', label: 'หน่วยนับ', type: 'text' }
          ]
        },
        {
          id: 'vendors',
          name: 'ข้อมูลเจ้าหนี้',
          icon: 'fa-solid fa-truck-field',
          table: 'vendors',
          columns: [
            { key: 'vendor_code', label: 'รหัสเจ้าหนี้' },
            { key: 'vendor_name', label: 'ชื่อเจ้าหนี้' },
            { key: 'tax_id', label: 'เลขผู้เสียภาษี' }
          ],
          fields: [
            { key: 'vendor_code', label: 'รหัสเจ้าหนี้', type: 'text' },
            { key: 'prefix', label: 'คำนำหน้า', type: 'text' },
            { key: 'vendor_name', label: 'ชื่อเจ้าหนี้', type: 'text' },
            { key: 'tax_id', label: 'เลขผู้เสียภาษี', type: 'text' },
            { key: 'address', label: 'ที่อยู่', type: 'textarea' }
          ]
        },
        {
          id: 'customers',
          name: 'ข้อมูลลูกค้า',
          icon: 'fa-solid fa-users',
          table: 'customers',
          columns: [
            { key: 'customer_code', label: 'รหัสลูกค้า' },
            { key: 'customer_name', label: 'ชื่อลูกค้า' },
            { key: 'customer_grade', label: 'เกรด' },
            { key: 'credit_days', label: 'เครดิต (วัน)' }
          ],
          fields: [
            { key: 'customer_code', label: 'รหัสลูกค้า', type: 'text' },
            { key: 'customer_name', label: 'ชื่อลูกค้า', type: 'text' },
            { key: 'customer_grade', label: 'เกรดลูกค้า', type: 'select', options: ['A', 'B', 'C', 'VIP'] },
            { key: 'credit_days', label: 'เครดิต (วัน)', type: 'number' },
            { key: 'address', label: 'ที่อยู่', type: 'textarea' }
          ]
        },
        {
          id: 'raw_materials',
          name: 'รหัสแม่ปุ๋ย',
          icon: 'fa-solid fa-cubes',
          table: 'raw_materials',
          columns: [
            { key: 'rm_code', label: 'รหัสแม่ปุ๋ย' },
            { key: 'rm_name', label: 'ชื่อแม่ปุ๋ย' },
            { key: 'n_percent', label: '%N' },
            { key: 'p_percent', label: '%P' },
            { key: 'k_percent', label: '%K' }
          ],
          fields: [
            { key: 'rm_code', label: 'รหัสแม่ปุ๋ย', type: 'text' },
            { key: 'rm_name', label: 'ชื่อแม่ปุ๋ย', type: 'text' },
            { key: 'n_percent', label: '%N', type: 'number' },
            { key: 'p_percent', label: '%P', type: 'number' },
            { key: 'k_percent', label: '%K', type: 'number' },
            { key: 's_percent', label: '%S', type: 'number' }
          ]
        },
        {
          id: 'products',
          name: 'สินค้าสำเร็จรูป (FG)',
          icon: 'fa-solid fa-box',
          table: 'products',
          columns: [
            { key: 'product_code', label: 'รหัสสินค้า' },
            { key: 'product_name', label: 'ชื่อสินค้า' },
            { key: 'product_type', label: 'ประเภท' },
            { key: 'pack_size', label: 'ขนาดบรรจุ' }
          ],
          fields: [
            { key: 'product_code', label: 'รหัสสินค้า', type: 'text' },
            { key: 'product_name', label: 'ชื่อสินค้า', type: 'text' },
            { key: 'product_type', label: 'ประเภทสินค้า', type: 'text' },
            { key: 'pack_size', label: 'ขนาดบรรจุ', type: 'text' },
            { key: 'formula', label: 'สูตร', type: 'text' }
          ]
        },
        {
          id: 'packaging',
          name: 'บรรจุภัณฑ์',
          icon: 'fa-solid fa-boxes-stacked',
          table: 'packaging',
          columns: [
            { key: 'pkg_code', label: 'รหัสกระสอบ' },
            { key: 'pkg_name', label: 'ชื่อกระสอบ' },
            { key: 'pack_size', label: 'ขนาด' },
            { key: 'unit_cost', label: 'ราคาทุน' }
          ],
          fields: [
            { key: 'pkg_code', label: 'รหัสกระสอบ', type: 'text' },
            { key: 'pkg_name', label: 'ชื่อกระสอบ', type: 'text' },
            { key: 'pack_size', label: 'ขนาด', type: 'text' },
            { key: 'unit_cost', label: 'ราคาทุน', type: 'number' }
          ]
        },
        {
          id: 'employees',
          name: 'จัดการพนักงาน (สิทธิ์)',
          icon: 'fa-solid fa-user-shield',
          table: 'employees',
          columns: [
            { key: 'username', label: 'ชื่อผู้ใช้งาน' },
            { key: 'full_name', label: 'ชื่อ-นามสกุล' },
            { key: 'role', label: 'สิทธิ์ (Role)' },
            { key: 'status', label: 'สถานะ' }
          ],
          fields: [
            { key: 'username', label: 'ชื่อผู้ใช้งาน (Username)', type: 'text' },
            { key: 'password', label: 'รหัสผ่าน (Password)', type: 'password' },
            { key: 'full_name', label: 'ชื่อ-นามสกุล', type: 'text' },
            { key: 'role', label: 'สิทธิ์การใช้งาน', type: 'select', options: ['admin', 'manager', 'operator', 'viewer'] },
            { key: 'status', label: 'สถานะ', type: 'select', options: ['ใช้งาน', 'ระงับ'] }
          ]
        }
      ]
    }
  },
  computed: {
    currentTabObj() {
      return this.tabs.find(t => t.id === this.currentTab) || this.tabs[0]
    },
    currentTitle() {
      if (this.currentTab === 'dashboard') return 'แดชบอร์ด & ภาพรวม'
      if (this.currentTab === 'reports') return 'รายงานข้อมูลทั้งหมด'
      return this.currentTabObj.name
    },
    filteredItems() {
      if (!this.searchQuery) return this.items
      const q = this.searchQuery.toLowerCase()
      return this.items.filter(item => {
        return Object.values(item).some(val => 
          String(val).toLowerCase().includes(q)
        )
      })
    }
  },
  watch: {
    currentTab(newTab) {
      this.searchQuery = ''
      if (!['dashboard', 'reports'].includes(newTab)) {
        this.fetchData()
      } else {
        this.fetchAllData()
      }
    },
    isLoggedIn(val) {
      if (val) {
        this.fetchAllData()
      }
    }
  },
  mounted() {
    if (this.isConfigured && this.isLoggedIn) {
      this.fetchAllData()
    }
  },
  methods: {
    saveConfig() {
      if (!this.tempUrl || !this.tempKey) {
        alert('กรุณากรอก URL และ Key ให้ครบถ้วน')
        return
      }
      localStorage.setItem('sb_url', this.tempUrl.trim())
      localStorage.setItem('sb_key', this.tempKey.trim())
      this.supabaseClient = createClient(this.tempUrl.trim(), this.tempKey.trim())
      this.isConfigured = true
    },
    async handleLogin() {
      this.loginLoading = true
      try {
        const { data, error } = await this.supabaseClient
          .from('employees')
          .select('*')
          .eq('username', this.loginForm.username)
          .eq('password', this.loginForm.password)
          .single()

        if (error || !data) {
          alert('ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง')
          return
        }

        if (data.status === 'ระงับ') {
          alert('บัญชีนี้ถูกระงับการใช้งาน')
          return
        }

        this.currentUser = data
        this.isLoggedIn = true
        localStorage.setItem('current_user', JSON.stringify(data))
        this.fetchAllData()
      } catch (err) {
        alert('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: ' + err.message)
      } finally {
        this.loginLoading = false
      }
    },
    handleLogout() {
      if (confirm('คุณต้องการออกจากระบบใช่หรือไม่?')) {
        localStorage.removeItem('current_user')
        this.isLoggedIn = false
        this.currentUser = {}
      }
    },
    resetConfig() {
      if (confirm('คุณต้องการเปลี่ยนการตั้งค่า Supabase ใช่หรือไม่?')) {
        localStorage.removeItem('sb_url')
        localStorage.removeItem('sb_key')
        this.isConfigured = false
      }
    },
    async fetchData() {
      if (!this.supabaseClient || ['dashboard', 'reports'].includes(this.currentTab)) return
      this.loading = true
      try {
        const { data, error } = await this.supabaseClient.from(this.currentTabObj.table).select('*').order('id', { ascending: false })
        if (error) throw error
        this.items = data || []
      } catch (err) {
        console.error('Error fetching data:', err.message)
      } finally {
        this.loading = false
      }
    },
    async fetchAllData() {
      if (!this.supabaseClient || !this.isLoggedIn) return
      for (const tab of this.tabs) {
        try {
          const { count, error } = await this.supabaseClient.from(tab.table).select('*', { count: 'exact', head: true })
          if (!error) this.counts[tab.id] = count || 0
        } catch (err) {
          console.error(`Error counting ${tab.id}:`, err)
        }
      }
    },
    openModal(item = null) {
      this.formData = {}
      if (item) {
        this.isEditing = true
        this.editingId = item.id
        this.formData = { ...item }
      } else {
        this.isEditing = false
        this.editingId = null
      }
      this.showModal = true
    },
    closeModal() {
      this.showModal = false
    },
    async saveItem() {
      try {
        if (this.isEditing) {
          const { error } = await this.supabaseClient.from(this.currentTabObj.table).update(this.formData).eq('id', this.editingId)
          if (error) throw error
        } else {
          delete this.formData.id
          const { error } = await this.supabaseClient.from(this.currentTabObj.table).insert([this.formData])
          if (error) throw error
        }
        this.closeModal()
        this.fetchData()
        this.fetchAllData()
      } catch (err) {
        alert('เกิดข้อผิดพลาด: ' + err.message)
      }
    },
    async deleteItem(id) {
      if (!confirm('คุณต้องการลบข้อมูลนี้ใช่หรือไม่?')) return
      try {
        const { error } = await this.supabaseClient.from(this.currentTabObj.table).delete().eq('id', id)
        if (error) throw error
        this.fetchData()
        this.fetchAllData()
      } catch (err) {
        alert('เกิดข้อผิดพลาด: ' + err.message)
      }
    }
  }
}
</script>
