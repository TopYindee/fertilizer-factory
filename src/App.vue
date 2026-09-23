<template>
  <div class="min-h-screen flex flex-col bg-gray-50">
    <!-- Supabase Config Modal if not set -->
    <div
      v-if="!isConfigured"
      class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4"
    >
      <div class="bg-white rounded-xl shadow-2xl max-w-md w-full p-6 space-y-4">
        <div class="text-center">
          <div
            class="w-12 h-12 bg-burgundy-100 text-burgundy-600 rounded-full flex items-center justify-center mx-auto mb-2 text-xl"
          >
            <i class="fa-solid fa-database"></i>
          </div>
          <h2 class="text-xl font-bold text-gray-900">ตั้งค่าการเชื่อมต่อ Supabase</h2>
          <p class="text-sm text-gray-500 mt-1">
            ยังไม่ได้ใส่ Supabase Anon Key<br />
            กรุณาเปิดไฟล์
            <code class="text-burgundy-600 font-semibold">src/supabaseConfig.js</code>
            แล้วนำ Anon Key มาใส่ หรือกรอกด้านล่างนี้:
          </p>
        </div>
        <div class="space-y-3">
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1"
              >Supabase URL</label
            >
            <input
              v-model="tempUrl"
              type="text"
              readonly
              class="w-full px-3 py-2 border rounded-lg text-xs bg-gray-100 text-gray-600"
            />
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1"
              >Supabase Anon Key</label
            >
            <input
              v-model="tempKey"
              type="password"
              placeholder="eyJhbGciOi..."
              class="w-full px-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            />
          </div>
          <button
            @click="saveConfig"
            class="w-full bg-burgundy-600 hover:bg-burgundy-700 text-white font-medium py-2 rounded-lg text-sm transition shadow"
          >
            บันทึกและเชื่อมต่อฐานข้อมูล
          </button>
        </div>
      </div>
    </div>

    <!-- Login View -->
    <div
      v-else-if="!isLoggedIn"
      class="min-h-screen flex items-center justify-center p-4 bg-burgundy-900"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 sm:p-8 space-y-6">
        <div class="text-center space-y-2">
          <div
            class="w-16 h-16 bg-burgundy-100 text-burgundy-600 rounded-2xl flex items-center justify-center mx-auto text-2xl shadow-inner"
          >
            <i class="fa-solid fa-industry"></i>
          </div>
          <p class="text-xs font-bold tracking-widest text-burgundy-600">
            บริษัท เวิลด์ เฟอท จำกัด
          </p>
          <h2 class="text-xl sm:text-2xl font-bold text-gray-900">
            ระบบบริหารจัดการโรงปุ๋ย
          </h2>
          <p class="text-xs text-gray-500">กรุณาเข้าสู่ระบบด้วยบัญชีพนักงานของคุณ</p>
        </div>
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1"
              >ชื่อผู้ใช้งาน (Username)</label
            >
            <input
              v-model="loginForm.username"
              type="text"
              placeholder="เช่น admin"
              required
              class="w-full px-3.5 py-2.5 border rounded-xl text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            />
          </div>
          <div>
            <label class="block text-xs font-semibold text-gray-700 mb-1"
              >รหัสผ่าน (Password)</label
            >
            <input
              v-model="loginForm.password"
              type="password"
              placeholder="••••••"
              required
              class="w-full px-3.5 py-2.5 border rounded-xl text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            />
          </div>
          <button
            type="submit"
            :disabled="loginLoading"
            class="w-full bg-burgundy-600 hover:bg-burgundy-700 text-white font-medium py-3 rounded-xl text-sm transition shadow-lg shadow-burgundy-600/30 flex items-center justify-center space-x-2"
          >
            <i v-if="loginLoading" class="fa-solid fa-spinner fa-spin"></i>
            <span>{{ loginLoading ? "กำลังตรวจสอบ..." : "เข้าสู่ระบบ" }}</span>
          </button>
          <div class="text-center pt-2">
            <p class="text-[11px] text-gray-400">
              บัญชีทดสอบเริ่มต้น: Username: <b>admin</b> | Password: <b>123456</b>
            </p>
          </div>
        </form>
      </div>
    </div>

    <!-- Main Layout -->
    <div v-else class="flex h-screen overflow-hidden relative">
      <!-- Mobile Sidebar Backdrop -->
      <div
        v-if="sidebarOpen"
        @click="sidebarOpen = false"
        class="fixed inset-0 bg-black/50 z-30 md:hidden"
      ></div>

      <!-- Sidebar -->
      <aside
        :class="{ 'translate-x-0': sidebarOpen, '-translate-x-full': !sidebarOpen }"
        class="fixed md:static inset-y-0 left-0 w-64 bg-burgundy-800 text-white flex flex-col shadow-xl z-40 transform transition-transform duration-200 ease-in-out md:translate-x-0"
      >
        <div class="p-4 border-b border-burgundy-700 flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <div class="bg-burgundy-600 p-2 rounded-lg text-white">
              <i class="fa-solid fa-industry text-lg"></i>
            </div>
            <div>
              <h1 class="font-bold text-base leading-tight">บริษัท เวิลด์ เฟอท จำกัด</h1>
              <p class="text-xs text-burgundy-100/70">Role: {{ currentUser.role }}</p>
            </div>
          </div>
          <button
            @click="sidebarOpen = false"
            class="md:hidden text-burgundy-100 hover:text-white p-1"
          >
            <i class="fa-solid fa-xmark text-lg"></i>
          </button>
        </div>

        <nav class="flex-1 overflow-y-auto p-3 space-y-1">
          <button
            @click="
              currentTab = 'dashboard';
              sidebarOpen = false;
            "
            :class="{
              'bg-burgundy-600 text-white': currentTab === 'dashboard',
              'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== 'dashboard',
            }"
            class="w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition"
          >
            <i class="fa-solid fa-chart-pie w-5 text-center"></i>
            <span>แดชบอร์ด & ภาพรวม</span>
          </button>

          <!-- ตั้งค่า / Master Data - พับได้ เผื่อ BOM/Stock ในอนาคตและจำกัดสิทธิ์ตาม role -->
          <button
            @click="masterDataOpen = !masterDataOpen"
            class="w-full flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition bg-burgundy-900/40 text-burgundy-100 hover:bg-burgundy-700/50 mt-3"
          >
            <div class="flex items-center space-x-3">
              <i class="fa-solid fa-gear w-5 text-center"></i>
              <span>ตั้งค่า / Master Data</span>
            </div>
            <i
              :class="masterDataOpen ? 'fa-chevron-up' : 'fa-chevron-down'"
              class="fa-solid text-[10px] opacity-70"
            ></i>
          </button>

          <div v-show="masterDataOpen" class="space-y-1 pl-2 border-l border-burgundy-700/50 ml-3 mt-1">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="
                currentTab = tab.id;
                sidebarOpen = false;
              "
              :class="{
                'bg-burgundy-600 text-white': currentTab === tab.id,
                'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== tab.id,
              }"
              class="w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition"
            >
              <i :class="tab.icon" class="w-5 text-center"></i>
              <span class="truncate">{{ tab.name }}</span>
            </button>

            <button
              @click="
                currentTab = 'reports';
                sidebarOpen = false;
              "
              :class="{
                'bg-burgundy-600 text-white': currentTab === 'reports',
                'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== 'reports',
              }"
              class="w-full flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition"
            >
              <i class="fa-solid fa-file-excel w-5 text-center"></i>
              <span>รายงานทั้งหมด</span>
            </button>
          </div>

          <button
            @click="
              currentTab = 'help';
              sidebarOpen = false;
            "
            :class="{
              'bg-burgundy-600 text-white': currentTab === 'help',
              'text-burgundy-100 hover:bg-burgundy-700/50': currentTab !== 'help',
            }"
            class="w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition mt-3 border border-burgundy-700/50"
          >
            <i class="fa-solid fa-book-open w-5 text-center"></i>
            <span>คู่มือการใช้งาน</span>
          </button>
        </nav>

        <div
          class="p-3 border-t border-burgundy-700 text-xs flex items-center justify-between text-burgundy-100/70"
        >
          <div class="truncate pr-2">
            <i class="fa-solid fa-user-circle mr-1"></i> {{ currentUser.full_name }}
          </div>
          <button
            @click="handleLogout"
            title="ออกจากระบบ"
            class="hover:text-white text-red-300"
          >
            <i class="fa-solid fa-right-from-bracket"></i>
          </button>
        </div>
      </aside>

      <!-- Content Area -->
      <main class="flex-1 flex flex-col overflow-hidden bg-gray-100 w-full">
        <!-- Top Navbar -->
        <header
          class="bg-white border-b h-14 flex items-center justify-between px-4 sm:px-6 shadow-sm shrink-0"
        >
          <div class="flex items-center space-x-3">
            <button
              @click="sidebarOpen = true"
              class="md:hidden text-gray-600 hover:text-gray-900 p-1.5 focus:outline-none"
            >
              <i class="fa-solid fa-bars text-lg"></i>
            </button>
            <h2 class="text-base sm:text-lg font-bold text-gray-800 truncate">
              {{ currentTitle }}
            </h2>
          </div>
          <div class="flex items-center space-x-3">
            <span
              class="text-[11px] sm:text-xs bg-emerald-100 text-emerald-800 px-2.5 py-1 rounded-full font-medium"
              ><i class="fa-solid fa-circle text-[8px] mr-1 text-emerald-500"></i> Online
              DB</span
            >
          </div>
        </header>

        <!-- Dynamic View -->
        <div class="flex-1 overflow-y-auto p-4 sm:p-6">
          <!-- Dashboard View -->
          <div v-if="currentTab === 'dashboard'" class="space-y-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div
                class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4"
              >
                <div
                  class="w-12 h-12 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center text-xl shrink-0"
                >
                  <i class="fa-solid fa-truck-field"></i>
                </div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">เจ้าหนี้ทั้งหมด</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.vendors }}</h3>
                </div>
              </div>
              <div
                class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4"
              >
                <div
                  class="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-lg flex items-center justify-center text-xl shrink-0"
                >
                  <i class="fa-solid fa-users"></i>
                </div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">ลูกค้าทั้งหมด</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.customers }}</h3>
                </div>
              </div>
              <div
                class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4"
              >
                <div
                  class="w-12 h-12 bg-amber-50 text-amber-600 rounded-lg flex items-center justify-center text-xl shrink-0"
                >
                  <i class="fa-solid fa-cubes"></i>
                </div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">รหัสแม่ปุ๋ย</p>
                  <h3 class="text-xl font-bold text-gray-800">
                    {{ counts.raw_materials }}
                  </h3>
                </div>
              </div>
              <div
                class="bg-white p-5 rounded-xl shadow-sm border flex items-center space-x-4"
              >
                <div
                  class="w-12 h-12 bg-purple-50 text-purple-600 rounded-lg flex items-center justify-center text-xl shrink-0"
                >
                  <i class="fa-solid fa-box"></i>
                </div>
                <div>
                  <p class="text-xs text-gray-500 font-medium">สินค้าสำเร็จรูป (FG)</p>
                  <h3 class="text-xl font-bold text-gray-800">{{ counts.products }}</h3>
                </div>
              </div>
            </div>

            <div class="bg-white p-6 rounded-xl shadow-sm border">
              <h3 class="text-base font-bold text-gray-800 mb-4">
                ยินดีต้อนรับ, {{ currentUser.full_name }} สู่ระบบบริหารจัดการโรงปุ๋ย<br />
                <span class="text-sm font-semibold text-burgundy-700"
                  >บริษัท เวิลด์ เฟอท จำกัด</span
                >
              </h3>
              <!-- <p class="text-sm text-gray-600 leading-relaxed">
                ระบบจัดการฐานข้อมูลและบริหารงานโรงปุ๋ยรองรับการใช้งานบนทุกอุปกรณ์ (Mobile,
                Tablet, Desktop)
                เลือกเมนูด้านซ้ายเพื่อเริ่มต้นจัดการข้อมูลหรือดูรายงานได้ทันที
              </p> -->
            </div>
          </div>

          <!-- Reports View -->
          <div v-else-if="currentTab === 'reports'" class="space-y-6">
            <div class="bg-white p-6 rounded-xl shadow-sm border">
              <h3 class="text-base font-bold text-gray-800 mb-4">
                ศูนย์รวมรายงานข้อมูลโรงปุ๋ย
              </h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div
                  v-for="tab in tabs"
                  :key="tab.id"
                  class="border p-4 rounded-lg flex items-center justify-between hover:bg-gray-50 transition"
                >
                  <div>
                    <h4 class="font-bold text-sm text-gray-800">
                      <i :class="tab.icon" class="mr-2 text-burgundy-600"></i
                      >{{ tab.name }}
                    </h4>
                    <p class="text-xs text-gray-500 mt-1">
                      จำนวนข้อมูลทั้งหมด: {{ counts[tab.id] || 0 }} รายการ
                    </p>
                  </div>
                  <button
                    @click="currentTab = tab.id"
                    class="bg-burgundy-50 text-burgundy-600 hover:bg-burgundy-600 hover:text-white px-3 py-1.5 rounded-lg text-xs font-medium transition shrink-0 ml-2"
                  >
                    ดูข้อมูล
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Help View -->
          <div v-else-if="currentTab === 'help'" class="space-y-6">
            <div class="bg-white p-6 rounded-xl shadow-sm border">
              <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-6">
                <div>
                  <h3 class="text-lg font-bold text-gray-800">
                    <i class="fa-solid fa-book-open mr-2 text-burgundy-600"></i>คู่มือการใช้งาน - บริษัท เวิลด์ เฟอท จำกัด
                  </h3>
                  <p class="text-xs text-gray-500 mt-1">ระบบบริหารจัดการโรงปุ๋ย | อัปเดต 23 ก.ย. 2026</p>
                </div>
                <div class="flex items-center space-x-2">
                  <button onclick="window.print()" class="bg-burgundy-600 hover:bg-burgundy-700 text-white px-4 py-2 rounded-lg text-xs font-medium flex items-center space-x-2">
                    <i class="fa-solid fa-print"></i><span>พิมพ์ / Save PDF</span>
                  </button>
                </div>
              </div>
              <div class="relative mb-6">
                <i class="fa-solid fa-search absolute left-3 top-3 text-gray-400 text-xs"></i>
                <input v-model="helpSearch" type="text" placeholder="ค้นหาหัวข้อ เช่น โกดัง, เจ้าหนี้..." class="w-full pl-9 pr-3 py-2 border rounded-lg text-sm focus:ring-2 focus:ring-burgundy-600 focus:outline-none" />
              </div>
              <div v-for="sec in filteredHelp" :key="sec.title" class="border rounded-xl p-5 mb-4 hover:shadow-sm transition bg-gray-50/30">
                <h4 class="font-bold text-sm text-burgundy-700 mb-2"><i :class="sec.icon" class="mr-2"></i>{{ sec.title }}</h4>
                <p class="text-xs text-gray-600 leading-relaxed whitespace-pre-line">{{ sec.body }}</p>
                <img
                  v-if="sec.image"
                  :src="'/docs/screenshots/' + sec.image"
                  :alt="sec.title"
                  class="mt-3 w-full rounded-lg border shadow-sm bg-white"
                  loading="lazy"
                  @error="(e) => (e.target.style.display = 'none')"
                />
                <div v-if="sec.tips" class="mt-3 bg-amber-50 border border-amber-200 rounded-lg p-3">
                  <p class="text-[11px] font-semibold text-amber-800"><i class="fa-solid fa-lightbulb mr-1"></i>เคล็ดลับ</p>
                  <p class="text-xs text-amber-700 mt-1">{{ sec.tips }}</p>
                </div>
              </div>
              <div class="text-center pt-4 border-t">
                <p class="text-xs text-gray-400">หากต้องการ Word/PDF แบบเต็ม ติดต่อผู้ดูแลระบบ หรือกด พิมพ์ → Save as PDF</p>
                <p class="text-[11px] text-gray-400 mt-1">Version 1.0 | รองรับ Mobile / Tablet / Desktop | สอบถาม: admin / 123456</p>
              </div>
            </div>
          </div>

          <!-- Standard CRUD Table View -->
          <div v-else class="space-y-4">
            <!-- Action Bar -->
            <div
              class="bg-white p-4 rounded-xl shadow-sm border flex flex-col sm:flex-row items-center justify-between gap-3"
            >
              <div class="w-full sm:w-72 relative">
                <i
                  class="fa-solid fa-search absolute left-3 top-3 text-gray-400 text-xs"
                ></i>
                <input
                  v-model="searchQuery"
                  type="text"
                  placeholder="ค้นหาข้อมูล..."
                  class="w-full pl-9 pr-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
                />
              </div>
              <div class="flex items-center space-x-2 w-full sm:w-auto">
                <button
                  @click="exportCurrentTab()"
                  class="flex-1 sm:flex-none bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 px-4 py-2 rounded-lg text-xs font-medium flex items-center justify-center space-x-2 transition"
                  title="ส่งออก Excel/CSV"
                >
                  <i class="fa-solid fa-file-excel text-emerald-600"></i>
                  <span>ส่งออก</span>
                </button>
                <button
                  @click="openModal()"
                  class="flex-1 sm:flex-none bg-burgundy-600 hover:bg-burgundy-700 text-white px-4 py-2 rounded-lg text-xs font-medium flex items-center justify-center space-x-2 transition shadow"
                >
                  <i class="fa-solid fa-plus"></i>
                  <span>เพิ่ม{{ currentTabObj.name }}</span>
                </button>
              </div>
            </div>

            <!-- Data Table -->
            <div class="bg-white rounded-xl shadow-sm border overflow-hidden">
              <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-xs">
                  <thead>
                    <tr class="bg-gray-50 border-b text-gray-600 uppercase font-semibold">
                      <!-- <th class="p-3 whitespace-nowrap">ID / รหัส</th> -->
                      <th
                        v-for="col in currentTabObj.columns"
                        :key="col.key"
                        class="p-3 whitespace-nowrap"
                      >
                        {{ col.label }}
                      </th>
                      <th class="p-3 text-center whitespace-nowrap">จัดการ</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-100">
                    <tr v-if="loading" class="text-center">
                      <td
                        :colspan="currentTabObj.columns.length + 1"
                        class="p-8 text-gray-400"
                      >
                        กำลังโหลดข้อมูล...
                      </td>
                    </tr>
                    <tr v-else-if="filteredItems.length === 0" class="text-center">
                      <td
                        :colspan="currentTabObj.columns.length + 1"
                        class="p-8 text-gray-400"
                      >
                        ไม่พบข้อมูล
                      </td>
                    </tr>
                    <tr
                      v-for="item in filteredItems"
                      :key="item.id"
                      class="hover:bg-gray-50/80 transition"
                    >
                      <!-- <td class="p-3 font-medium text-gray-900 whitespace-nowrap">{{ item.code_id || item.id }}</td> -->
                      <td
                        v-for="col in currentTabObj.columns"
                        :key="col.key"
                        class="p-3 text-gray-600"
                      >
                        {{ formatCellValue(item[col.key], col.key) }}
                      </td>
                      <td class="p-3 text-center space-x-2 whitespace-nowrap">
                        <button
                          @click="openModal(item)"
                          class="text-blue-600 hover:text-blue-800 p-1"
                          title="แก้ไข"
                        >
                          <i class="fa-solid fa-pen-to-square"></i>
                        </button>
                        <button
                          @click="deleteItem(item.id)"
                          class="text-red-600 hover:text-red-800 p-1"
                          title="ลบ"
                        >
                          <i class="fa-solid fa-trash"></i>
                        </button>
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
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 overflow-y-auto"
    >
      <div
        class="bg-white rounded-xl shadow-2xl max-w-xl w-full max-h-[90vh] flex flex-col my-auto"
      >
        <div class="p-4 border-b flex items-center justify-between shrink-0">
          <h3 class="font-bold text-gray-800 text-sm">
            {{ isEditing ? "แก้ไข" : "เพิ่ม" }}{{ currentTabObj.name }}
          </h3>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <i class="fa-solid fa-xmark text-lg"></i>
          </button>
        </div>

        <!-- Custom Modal Body for Warehouses -->
        <div
          v-if="currentTab === 'warehouses'"
          class="p-6 overflow-y-auto space-y-4 flex-1"
        >
          <div
            class="grid grid-cols-1 sm:grid-cols-3 gap-3 bg-gray-50 p-4 rounded-xl border"
          >
            <div>
              <label class="block text-xs font-semibold text-gray-700 mb-1"
                >เลือกประเภทโกดัง</label
              >
              <select
                v-model="warehouseForm.type"
                @change="onWarehouseTypeChange"
                class="w-full px-3 py-2 border rounded-lg text-xs bg-white focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
              >
                <option value="โกดังวัตถุดิบ(แม่ปุ๋ย)">โกดังวัตถุดิบ(แม่ปุ๋ย)</option>
                <option value="โกดังสินค้าFG">โกดังสินค้าFG</option>
                <option value="โกดังบรรจุภัณฑ์PKG">โกดังบรรจุภัณฑ์PKG</option>
              </select>
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-700 mb-1"
                >รหัสโกดังหลัก</label
              >
              <input
                v-model="warehouseForm.mainCode"
                type="text"
                readonly
                class="w-full px-3 py-2 border rounded-lg text-xs bg-gray-100 text-gray-600 font-semibold"
              />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-700 mb-1"
                >จำนวนโซนย่อย</label
              >
              <input
                v-model="warehouseForm.zoneCount"
                type="number"
                min="1"
                max="10"
                placeholder="เช่น 1"
                @input="updateZones"
                @blur="ensureZoneCount"
                @focus="$event.target.select()"
                class="w-full px-3 py-2 border rounded-lg text-xs bg-white focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
              />
            </div>
          </div>

          <div class="space-y-3">
            <label class="block text-xs font-semibold text-gray-700"
              >ระบุปริมาณจัดเก็บแยกตามโซนย่อย:</label
            >
            <div
              v-for="(zone, index) in warehouseForm.zones"
              :key="index"
              class="flex flex-col sm:flex-row items-start sm:items-center space-y-2 sm:space-y-0 sm:space-x-3 bg-gray-50/70 p-3 rounded-lg border"
            >
              <div
                class="w-16 font-bold text-burgundy-700 text-xs bg-burgundy-100 px-3 py-1.5 rounded text-center"
              >
                {{ zone.name }}
              </div>
              <div class="flex-1 flex items-center space-x-2 w-full sm:w-auto">
                <span class="text-xs text-gray-600"
                  >ปริมาณ ({{ getWarehouseUnitLabel }}) :</span
                >
                <input
                  :value="zone.capacity === 0 ? '' : zone.capacity"
                  @input="
                    zone.capacity =
                      $event.target.value === '' ? '' : Number($event.target.value)
                  "
                  @blur="zone.capacity === '' && (zone.capacity = 0)"
                  @focus="$event.target.select()"
                  type="number"
                  min="0"
                  placeholder="0"
                  class="w-28 px-3 py-1.5 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
                />
              </div>
              <div class="text-[11px] text-gray-500 whitespace-nowrap">
                {{ getFormattedUnitText(zone.capacity) }}
              </div>
            </div>
          </div>
        </div>

        <!-- Standard Modal Body for other tabs -->
        <div v-else class="p-6 overflow-y-auto space-y-4 flex-1">
          <div v-for="field in currentTabObj.fields" :key="field.key">
            <label class="block text-xs font-semibold text-gray-700 mb-1"
              >{{ field.label
              }}<span v-if="isRequired(field.key)" class="text-red-500 ml-0.5"
                >*</span
              ></label
            >
            <input
              v-if="
                field.type === 'text' ||
                field.type === 'number' ||
                field.type === 'password' ||
                field.type === 'date'
              "
              :type="field.type"
              v-model="formData[field.key]"
              :placeholder="field.placeholder || ''"
              :readonly="
                field.key === 'vendor_code' ||
                field.key === 'customer_code' ||
                field.key === 'rm_code' ||
                field.key === 'product_code' ||
                field.key === 'pkg_code' ||
                field.key === 'unit'
              "
              :class="[
                isRequired(field.key) && !formData[field.key] ? 'border-red-400 bg-red-50' : '',
                {
                  'bg-gray-100 text-gray-600 font-semibold':
                    field.key === 'vendor_code' ||
                    field.key === 'customer_code' ||
                    field.key === 'rm_code' ||
                    field.key === 'product_code' ||
                    field.key === 'pkg_code' ||
                    field.key === 'unit',
                },
              ]"
              class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            />
            <textarea
              v-else-if="field.type === 'textarea'"
              v-model="formData[field.key]"
              :placeholder="field.placeholder || ''"
              rows="3"
              class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            ></textarea>
            <select
              v-else-if="field.type === 'select'"
              v-model="formData[field.key]"
              class="w-full px-3 py-2 border rounded-lg text-xs focus:ring-2 focus:ring-burgundy-600 focus:outline-none"
            >
              <option v-if="field.key === 'vendor'" value="">
                -- เลือกจาก Vendor --
              </option>
              <option v-if="field.key === 'fg_code'" value="">
                -- เลือกจาก FG List --
              </option>
              <option v-if="field.key === 'formula'" value="">
                -- ดึงมาจากสูตรการผลิต --
              </option>
              <option v-for="opt in field.options" :key="opt" :value="opt">
                {{ opt }}
              </option>
            </select>
          </div>
        </div>

        <div class="p-4 border-t bg-gray-50 flex justify-end space-x-2 shrink-0">
          <button
            @click="closeModal"
            class="px-4 py-2 border rounded-lg text-xs font-medium text-gray-600 hover:bg-gray-100"
          >
            ยกเลิก
          </button>
          <button
            @click="currentTab === 'warehouses' ? saveWarehouses() : saveItem()"
            :disabled="warehouseSaving"
            class="px-4 py-2 bg-burgundy-600 hover:bg-burgundy-700 text-white rounded-lg text-xs font-medium shadow flex items-center space-x-2"
          >
            <i v-if="warehouseSaving" class="fa-solid fa-spinner fa-spin"></i>
            <span>บันทึก</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Custom Confirm Modal (สีสื่อความหมาย) -->
    <div
      v-if="confirmVisible"
      class="fixed inset-0 bg-black/60 z-[60] flex items-center justify-center p-4"
      @click.self="confirmVisible = false"
    >
      <div class="bg-white rounded-xl shadow-2xl max-w-sm w-full overflow-hidden">
        <div
          :class="{
            'bg-red-50 text-red-600': confirmType === 'delete',
            'bg-amber-50 text-amber-600': confirmType === 'logout',
            'bg-emerald-50 text-emerald-600': confirmType === 'success',
            'bg-blue-50 text-blue-600': confirmType === 'info',
          }"
          class="p-4 flex items-center space-x-3"
        >
          <div
            :class="{
              'bg-red-100': confirmType === 'delete',
              'bg-amber-100': confirmType === 'logout',
              'bg-emerald-100': confirmType === 'success',
              'bg-blue-100': confirmType === 'info',
            }"
            class="w-10 h-10 rounded-full flex items-center justify-center text-lg shrink-0"
          >
            <i
              :class="{
                'fa-solid fa-trash': confirmType === 'delete',
                'fa-solid fa-right-from-bracket': confirmType === 'logout',
                'fa-solid fa-check': confirmType === 'success',
                'fa-solid fa-circle-info': confirmType === 'info',
              }"
            ></i>
          </div>
          <h3 class="font-bold text-sm text-gray-800">{{ confirmTitle }}</h3>
        </div>
        <div class="p-4">
          <p class="text-sm text-gray-600 leading-relaxed">{{ confirmMessage }}</p>
        </div>
        <div class="p-3 bg-gray-50 flex justify-end space-x-2">
          <button
            @click="confirmVisible = false"
            class="px-4 py-1.5 border rounded-lg text-xs font-medium text-gray-600 hover:bg-white"
          >
            ยกเลิก
          </button>
          <button
            @click="handleConfirm"
            :class="{
              'bg-red-600 hover:bg-red-700': confirmType === 'delete',
              'bg-amber-600 hover:bg-amber-700': confirmType === 'logout',
              'bg-emerald-600 hover:bg-emerald-700': confirmType === 'success',
              'bg-burgundy-600 hover:bg-burgundy-700': confirmType === 'info',
            }"
            class="px-4 py-1.5 text-white rounded-lg text-xs font-medium shadow"
          >
            ยืนยัน
          </button>
        </div>
      </div>
    </div>

    <!-- Toast สีเขียว/แดง สื่อสำเร็จ/ผิดพลาด - กลางบนเด่นชัด -->
    <div
      v-if="toastVisible"
      class="fixed top-6 left-1/2 -translate-x-1/2 z-[70] flex items-center space-x-3 px-6 py-3 rounded-xl shadow-xl text-sm font-medium text-white transition"
      :class="{
        'bg-emerald-600': toastType === 'success',
        'bg-red-600': toastType === 'error',
        'bg-blue-600': toastType === 'info',
      }"
    >
      <i
        :class="{
          'fa-solid fa-check-circle': toastType === 'success',
          'fa-solid fa-circle-exclamation': toastType === 'error',
          'fa-solid fa-circle-info': toastType === 'info',
        }"
      ></i>
      <span>{{ toastMessage }}</span>
    </div>
  </div>
</template>

<script>
import { createClient } from "@supabase/supabase-js";
import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./supabaseConfig.js";

export default {
  name: "App",
  data() {
    const supabaseUrl = SUPABASE_URL || localStorage.getItem("sb_url") || "";
    const supabaseKey =
      (SUPABASE_ANON_KEY !== "วาง_Anon_Key_ของคุณที่นี่" ? SUPABASE_ANON_KEY : "") ||
      localStorage.getItem("sb_key") ||
      "";
    const savedUser = JSON.parse(localStorage.getItem("current_user") || "null");

    return {
      sidebarOpen: false,
      supabaseUrl,
      supabaseKey,
      isConfigured: !!supabaseUrl && !!supabaseKey,
      tempUrl: supabaseUrl,
      tempKey: supabaseKey,
      supabaseClient:
        supabaseUrl && supabaseKey ? createClient(supabaseUrl, supabaseKey) : null,

      isLoggedIn: !!savedUser,
      currentUser: savedUser || {},
      loginForm: { username: "", password: "" },
      loginLoading: false,

      currentTab: "dashboard",
      masterDataOpen: false,
      searchQuery: "",
      loading: false,
      items: [],
      showModal: false,
      isEditing: false,
      editingId: null,
      formData: {},

      helpSearch: "",
      // dynamic dropdown options for packaging
      vendorOptions: [],
      productOptions: [],

      warehouseForm: {
        type: "โกดังวัตถุดิบ(แม่ปุ๋ย)",
        mainCode: "WH-RAW-001",
        zoneCount: 1,
        zones: [{ name: "Z01", capacity: 0 }],
      },
      warehouseSaving: false,
      // custom confirm / toast (แทน confirm/alert เดิม)
      confirmVisible: false,
      confirmTitle: "",
      confirmMessage: "",
      confirmType: "delete",
      confirmAction: null,
      toastVisible: false,
      toastMessage: "",
      toastType: "success",

      counts: {
        vendors: 0,
        customers: 0,
        raw_materials: 0,
        products: 0,
        packaging: 0,
        companies: 0,
        crop_years: 0,
        warehouses: 0,
        employees: 0,
      },
      tabs: [
        {
          id: "companies",
          name: "ข้อมูลบริษัท",
          icon: "fa-solid fa-building",
          table: "companies",
          columns: [
            { key: "thai_name", label: "ชื่อไทย" },
            { key: "eng_name", label: "ชื่ออังกฤษ" },
            { key: "branch", label: "สาขา" },
            { key: "tax_id", label: "เลขผู้เสียภาษี" },
            { key: "address", label: "ที่อยู่" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "thai_name", label: "ชื่อไทย", type: "text" },
            { key: "eng_name", label: "ชื่ออังกฤษ", type: "text" },
            {
              key: "branch",
              label: "สาขา",
              type: "select",
              options: ["สำนักงานใหญ่", "สาขา 2", "สาขา 3"],
            },
            { key: "tax_id", label: "เลขผู้เสียภาษี", type: "text" },
            { key: "address", label: "ที่อยู่", type: "textarea" },
          ],
        },
        {
          id: "crop_years",
          name: "ปีการผลิต",
          icon: "fa-solid fa-calendar-days",
          table: "crop_years",
          columns: [
            { key: "year_code", label: "รหัสปี" },
            { key: "start_date", label: "วันเริ่ม" },
            { key: "end_date", label: "วันจบ" },
            { key: "status", label: "สถานะ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "year_code", label: "รหัสปี", type: "text", placeholder: "เช่น 2026" },
            { key: "start_date", label: "วันเริ่ม", type: "date" },
            { key: "end_date", label: "วันจบ", type: "date" },
            { key: "status", label: "สถานะ", type: "select", options: ["เปิด", "ปิด"] },
          ],
        },
        {
          id: "warehouses",
          name: "ตั้งค่าโกดัง",
          icon: "fa-solid fa-warehouse",
          table: "warehouses",
          columns: [
            { key: "warehouse_type", label: "ประเภทโกดัง" },
            { key: "main_code", label: "รหัสโกดังหลัก" },
            { key: "sub_zone", label: "โซนย่อย" },
            { key: "capacity", label: "ปริมาณจัดเก็บ" },
            { key: "unit", label: "หน่วยนับ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
        },
        {
          id: "vendors",
          name: "ข้อมูลเจ้าหนี้",
          icon: "fa-solid fa-truck-field",
          table: "vendors",
          columns: [
            { key: "vendor_code", label: "รหัสเจ้าหนี้" },
            { key: "old_code", label: "รหัสเก่า" },
            { key: "prefix", label: "คำนำหน้า" },
            { key: "vendor_name", label: "ชื่อเจ้าหนี้" },
            { key: "vendor_type", label: "ประเภท" },
            { key: "tax_id", label: "เลขผู้เสียภาษี" },
            { key: "address", label: "ที่อยู่" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "vendor_code", label: "รหัสเจ้าหนี้", type: "text" },
            { key: "old_code", label: "รหัสเก่า", type: "text" },
            { key: "prefix", label: "คำนำหน้า", type: "text" },
            { key: "vendor_name", label: "ชื่อเจ้าหนี้", type: "text" },
            { key: "vendor_type", label: "ประเภท", type: "select", options: ["1", "2"] },
            { key: "tax_id", label: "เลขผู้เสียภาษี", type: "text" },
            { key: "address", label: "ที่อยู่", type: "textarea" },
          ],
        },
        {
          id: "customers",
          name: "ข้อมูลลูกค้า",
          icon: "fa-solid fa-users",
          table: "customers",
          columns: [
            { key: "customer_code", label: "รหัสลูกค้า" },
            { key: "old_code", label: "รหัสเก่า" },
            { key: "prefix", label: "คำนำหน้า" },
            { key: "customer_name", label: "ชื่อลูกค้า" },
            { key: "customer_type", label: "ประเภท" },
            { key: "credit_status", label: "สถานะเครดิต" },
            { key: "customer_grade", label: "เกรด" },
            { key: "credit_days", label: "เครดิต (วัน)" },
            { key: "address", label: "ที่อยู่" },
            { key: "notes", label: "หมายเหตุ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "customer_code", label: "รหัสลูกค้า", type: "text" },
            { key: "old_code", label: "รหัสเก่า", type: "text" },
            { key: "prefix", label: "คำนำหน้า", type: "text" },
            { key: "customer_name", label: "ชื่อลูกค้า", type: "text" },

            {
              key: "customer_type",
              label: "ประเภท",
              type: "select",
              options: ["1", "2"],
            },
            {
              key: "credit_status",
              label: "สถานะเครดิต",
              type: "select",
              options: ["ปกติ", "ค้าง"],
            },
            {
              key: "customer_grade",
              label: "เกรดลูกค้า",
              type: "select",
              options: ["A", "B", "C", "D"],
            },
            { key: "credit_days", label: "เครดิต (วัน)", type: "number", placeholder: "0" },
            { key: "address", label: "ที่อยู่", type: "textarea" },
             { key: "notes", label: "หมายเหตุ", type: "textarea" }
          ],
        },
        {
          id: "raw_materials",
          name: "รหัสแม่ปุ๋ย",
          icon: "fa-solid fa-cubes",
          table: "raw_materials",
          columns: [
            { key: "rm_code", label: "รหัสแม่ปุ๋ย" },
            { key: "rm_name", label: "ชื่อแม่ปุ๋ย" },
            { key: "rm_type", label: "ประเภท" },
            { key: "n_percent", label: "%N" },
            { key: "p_percent", label: "%P" },
            { key: "k_percent", label: "%K" },
            { key: "s_percent", label: "%S" },
            { key: "cao_percent", label: "%CaO" },
            { key: "mgo_percent", label: "%MgO" },
            { key: "notes", label: "หมายเหตุ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "rm_code", label: "รหัสแม่ปุ๋ย", type: "text" },
            { key: "rm_name", label: "ชื่อแม่ปุ๋ย", type: "text" },
            { key: "rm_type", label: "ประเภท", type: "select", options: ["ธาตุอาหาร", "FILLER"] },
            { key: "n_percent", label: "%N", type: "number", placeholder: "0" },
            { key: "p_percent", label: "%P", type: "number" , placeholder: "0"},
            { key: "k_percent", label: "%K", type: "number" , placeholder: "0"},
            { key: "s_percent", label: "%S", type: "number" , placeholder: "0"},
            { key: "cao_percent", label: "%CaO" , type: "number" , placeholder: "0"},
            { key: "mgo_percent", label: "%MgO" , type: "number" , placeholder: "0"},
            { key: "notes", label: "หมายเหตุ" , type: "textarea"},
          ],
        },
        {
          id: "products",
          name: "สินค้าสำเร็จรูป (FG)",
          icon: "fa-solid fa-box",
          table: "products",
          columns: [
            { key: "product_code", label: "รหัสสินค้า" },
            { key: "old_code", label: "รหัสเก่า" },
            { key: "product_name", label: "ชื่อสินค้า" },
            { key: "product_type", label: "ประเภท" },
            { key: "brand", label: "แบรนด์สินค้า" },
            { key: "pack_size", label: "ขนาดบรรจุ" },
            { key: "formula", label: "สูตรที่ใช้" },
            { key: "notes", label: "หมายเหตุ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "product_code", label: "รหัสสินค้า", type: "text" },
            { key: "old_code", label: "รหัสเก่า" ,type:"text"},
            { key: "product_name", label: "ชื่อสินค้า", type: "text" },
            { key: "product_type", label: "ประเภทสินค้า", type: "select", options: ["BB", "HP","CP"]  },
            { key: "brand", label: "แบรนด์สินค้า",type:"text" },
            { key: "pack_size", label: "ขนาดบรรจุ", type: "select", options: ["50 kg", "1,000 kg","1,200 kg"] },
            { key: "formula", label: "สูตรที่ใช้", type: "select", options: [], placeholder: "-- ดึงมาจากสูตรการผลิต --" },
            { key: "notes", label: "หมายเหตุ",type:"textarea" },
          ],
        },
        {
          id: "packaging",
          name: "บรรจุภัณฑ์",
          icon: "fa-solid fa-boxes-stacked",
          table: "packaging",
          columns: [
            { key: "pkg_code", label: "รหัสกระสอบ" },
            { key: "old_code", label: "รหัสเก่า" },
            { key: "pkg_name", label: "ชื่อกระสอบ" },
            { key: "pack_size", label: "ขนาด" },
            { key: "unit", label: "หน่วยนับ" },
            { key: "vendor", label: "ผู้ขาย" },
            { key: "unit_cost", label: "ราคาทุน" },
            { key: "fg_code", label: "รหัส FG" },
            { key: "notes", label: "หมายเหตุ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "pkg_code", label: "รหัสกระสอบ", type: "text", placeholder: "เช่น PKG-001" },
            { key: "old_code", label: "รหัสเก่า" ,type:"text"},
            { key: "pkg_name", label: "ชื่อกระสอบ", type: "text" },
            { key: "pack_size", label: "ขนาด", type: "select", options: ["50 kg", "1,000 kg","1,200 kg"] },
            { key: "unit", label: "หน่วยนับ", type: "text", placeholder: "ใบ" },
            { key: "vendor", label: "ผู้ขาย (ดึงจากเจ้าหนี้)", type: "select", options: [] },
            { key: "fg_code", label: "รหัส FG (ดึงจากสินค้า)", type: "select", options: [] },
            { key: "unit_cost", label: "ราคาทุน", type: "number", placeholder: "0" },
            { key: "notes", label: "หมายเหตุ",type:"textarea" },
          ],
        },
        {
          id: "employees",
          name: "จัดการพนักงาน (สิทธิ์)",
          icon: "fa-solid fa-user-shield",
          table: "employees",
          columns: [
            { key: "username", label: "ชื่อผู้ใช้งาน" },
            { key: "full_name", label: "ชื่อ-นามสกุล" },
            { key: "role", label: "สิทธิ์ (Role)" },
            { key: "status", label: "สถานะ" },
            { key: "created_at", label: "บันทึกเมื่อ" },
          ],
          fields: [
            { key: "username", label: "ชื่อผู้ใช้งาน (Username)", type: "text" },
            { key: "password", label: "รหัสผ่าน (Password)", type: "password" },
            { key: "full_name", label: "ชื่อ-นามสกุล", type: "text" },
            {
              key: "role",
              label: "สิทธิ์การใช้งาน",
              type: "select",
              options: ["admin", "manager", "operator", "viewer"],
            },
            {
              key: "status",
              label: "สถานะ",
              type: "select",
              options: ["ใช้งาน", "ระงับ"],
            },
          ],
        },
      ],
      helpSections: [
        { title: "1. เข้าสู่ระบบ", icon: "fa-solid fa-right-to-bracket", body: "1) เปิดเว็บ → เจอหน้า Login 'บริษัท เวิลด์ เฟอท จำกัด'\n2) กรอก Username / Password\n   - ทดสอบ: admin / 123456 (admin)\n3) กด 'เข้าสู่ระบบ'\n- ถ้าถูก → ไปหน้า แดชบอร์ด + นับ counts ทุกตาราง\n- ถ้าผิด → Toast แดงกลางบน 'ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง'\n- ถ้าถูกระงับ (status=ระงับ) → Toast แดง 'บัญชีนี้ถูกระงับ' เข้าไม่ได้", tips: "ลืมรหัสให้ติดต่อ admin ที่เมนู จัดการพนักงาน → แก้รหัสผ่าน" },
        { title: "2. แดชบอร์ด & ภาพรวม", icon: "fa-solid fa-chart-pie", body: "ดูยอดรวม 4 กล่องบน: เจ้าหนี้/ลูกค้า/แม่ปุ๋ย/FG (counts จาก Supabase)\n- Online DB สีเขียว = เชื่อมต่อ supabaseConfig.js สำเร็จ\n- ข้อความต้อนรับ: 'ยินดีต้อนรับ, ชื่อ สู่ระบบ... บริษัท เวิลด์ เฟอท จำกัด'\n- กดเมนูซ้ายเพื่อไปหน้าอื่น (มือถือกด ☰ มี backdrop ดำ)", tips: "ตัวเลขจะอัปเดตทันทีหลังเพิ่ม/ลบข้อมูล (fetchAllData)" },
        { title: "3. ตั้งค่า / Master Data (พับได้)", icon: "fa-solid fa-gear", body: "เมนู 'ตั้งค่า / Master Data' (fa-gear) จะพับไว้ตอนเปิดมา กดค่อยกาง\n- ข้างในมี 9 รายการ: ข้อมูลบริษัท / ปีการผลิต / ตั้งค่าโกดัง / เจ้าหนี้ / ลูกค้า / แม่ปุ๋ย / FG / บรรจุภัณฑ์ / พนักงาน + รายงานทั้งหมด\n- ออกแบบให้เพิ่มกลุ่มใหม่ในอนาคตได้ เช่น 'ผลิต & สต๊อก → BOM, คลัง, แผนผลิต' / 'จัดซื้อ-ขาย → PO, SO'\n- เตรียมกรองตาม Role: admin/manager/operator/viewer (currentUser.role)", tips: "พับไว้ช่วยให้จอไม่รก โดยเฉพาะมือถือ" },
        { title: "4. วิธีใช้งานมาตรฐานทุกหน้า Master Data", icon: "fa-solid fa-table", body: "ทุกหน้าใช้โครงเดียวกัน (Action Bar + ตาราง + Modal):\n1) ค้นหา: พิมพ์ในช่องค้นหา → กรอง filteredItems ทันที\n2) เพิ่ม: ปุ่ม '+ เพิ่ม...' มุมขวา → Modal ฟอร์มขึ้นมา\n3) แก้ไข: กดไอคอนปากกา (สีน้ำเงิน) ท้ายแถว\n4) ลบ: กดถังขยะแดง → Modal แดง 'ยืนยันการลบ' → ยืนยันถึงลบ + Toast เขียวกลางบน 'ลบสำเร็จ'\n5) ส่งออก: ปุ่ม 'ส่งออก' (fa-file-excel) ข้างปุ่มเพิ่ม → โหลด CSV พร้อม BOM ภาษาไทย ตามที่กรองอยู่ (vendors-2026-09-23.csv)\n6) ฟิลด์ * สีแดงคือบังคับ ถ้าว่างขอบจะแดง bg-red-50 + Toast แดง 'กรุณากรอก ...' + focus ช่องแรก", tips: "ส่งออกจะเอาเฉพาะที่เห็นหลังค้นหา - ค้นหา 'YARA' แล้วส่งออกจะได้แค่ YARA" },
        { title: "5. ข้อมูลบริษัท", icon: "fa-solid fa-building", image: "companies.png", body: "ฟิลด์: ชื่อไทย* (บังคับ) / ชื่ออังกฤษ / สาขา (dropdown: สำนักงานใหญ่, สาขา 2, สาขา 3 ดีฟอลต์ 'สำนักงานใหญ่') / เลขผู้เสียภาษี / ที่อยู่ (textarea)\n- เพิ่ม: ใส่ชื่อไทยแล้วเลือกสาขา (ขึ้นรอ) → บันทึก\n- แก้ไข: กดปากกา → แก้แล้วบันทึก → Toast เขียว\n- ตัวอย่างที่มี: บริษัท เวิลด์ เฟอท จำกัด / 105531024397 / 933 ถนนมหาไชย", tips: "สาขาเลือกได้ ไม่ต้องพิมพ์ - ตั้งดีฟอลต์ให้แล้ว" },
        { title: "6. ปีการผลิต", icon: "fa-solid fa-calendar-days", image: "crop_years.png", body: "ฟิลด์: รหัสปี* (เช่น 2026, placeholder) / วันเริ่ม* (type=date dd/mm/yyyy) / วันจบ* (type=date) / สถานะ (เปิด/ปิด ดีฟอลต์ 'เปิด')\n- ทั้ง 3 ช่อง * ต้องกรอกครบ (เราเพิ่ม start_date, end_date เป็นบังคับ)\n- วันเริ่ม-จบใช้เลือกจากปฏิทิน ไม่ต้องพิมพ์\n- ใช้กำหนดขอบเขตผลิตแต่ละปี", tips: "ต้องกรอกวันเริ่ม-จบให้ครบ ไม่งั้นบันทึกไม่ได้ (ขอบแดงเตือน)" },
        { title: "7. ตั้งค่าโกดังแบบ Zone", icon: "fa-solid fa-warehouse", image: "warehouses.png", body: "ขั้นตอน:\n1) เลือกประเภทโกดัง: วัตถุดิบ(แม่ปุ๋ย)/สินค้าFG/บรรจุภัณฑ์PKG → รหัสหลักจะรัน WH-RAW-002 / WH-FG-001 / WH-PKG-001 อัตโนมัติ (readonly สีเทา)\n2) ใส่ 'จำนวนโซนย่อย' 1-10 (ลบ 1 ได้, พิมพ์ว่างได้ตอนพิมพ์, blur ถึง clamp 1-10) → ช่องปริมาณจะโผล่ตามจำนวน (Z01, Z02...)\n3) ใส่ปริมาณต่อโซน: โฟกัสแล้ว select() พิมพ์ทับได้เลย ไม่เป็น 02, ถ้าว่างจะ placeholder 0, blur ว่าง→0\n4) หน่วย: โกดังวัตถุดิบ/FG โชว์ 'ตัน (กระสอบ 50กก.)' = ตัน*20, บรรจุภัณฑ์โชว์ 'ใบ'\n5) กดบันทึก → สร้างหลายแถว (1 แถวต่อ 1 โซน) พร้อม code_id = ID-xxxxx", tips: "ลดจำนวนโซน ปริมาณโซนที่เกินจะหาย - เช็คให้ดีก่อนบันทึก / zoneCount เริ่มต้น 1 มี Z01 รอเลย" },
        { title: "8. ข้อมูลเจ้าหนี้ (Vendor)", icon: "fa-solid fa-truck-field", image: "vendors.png", body: "ฟิลด์: รหัสเจ้าหนี้* (VEND-*** รันต่อ readonly เทา, รหัสล่าสุด VEND-003 → ขึ้น VEND-004 รอ), รหัสเก่า (ให้กรอกเอง), คำนำหน้า, ชื่อเจ้าหนี้*, ประเภท (1/2 ดีฟอลต์ 1 ขึ้นรอ), เลขผู้เสียภาษี, ที่อยู่\n- เพิ่ม: รหัสขึ้นรอเลย + เลือกประเภท → ใส่ชื่อ → บันทึก\n- ตัวอย่าง: VEND-001 : ท่านากะเซริสซีเมนเตอร์", tips: "รหัสเก่าไม่ล็อค ให้กรอกเองได้ (เช่น 01, 02) ต่างจาก VEND-***" },
        { title: "9. ข้อมูลลูกค้า (Customer)", icon: "fa-solid fa-users", image: "customers.png", body: "ฟิลด์: รหัสลูกค้า* (CUST-*** รันต่อ readonly), รหัสเก่า, คำนำหน้า, ชื่อลูกค้า*, ประเภท (1/2 ดีฟอลต์ 1), สถานะเครดิต (ปกติ/ค้าง ดีฟอลต์ ปกติ), เกรด (A/B/C/D ดีฟอลต์ A), เครดิต(วัน) (placeholder 0), ที่อยู่, หมายเหตุ\n- เพิ่ม: รหัสขึ้นรอ + 3 dropdown ดีฟอลต์ขึ้นรอ → ใส่ชื่อ → บันทึก\n- ตัวอย่าง: CUST-001 : 620001", tips: "เครดิต(วัน) ว่างจะโชว์ 0 จางๆ พิมพ์ทับได้" },
        { title: "10. รหัสแม่ปุ๋ย (Raw Material)", icon: "fa-solid fa-cubes", image: "raw_materials.png", body: "ฟิลด์: รหัสแม่ปุ๋ย* (RM-*** รันต่อ readonly), ชื่อแม่ปุ๋ย*, ประเภท (ธาตุอาหาร/FILLER ดีฟอลต์ 'ธาตุอาหาร' ขึ้นรอ), %N/%P/%K/%S/%CaO/%MgO (placeholder 0), หมายเหตุ\n- เพิ่ม: รหัส RM-006 ขึ้นรอ + ประเภทขึ้นรอ → ใส่ชื่อ เช่น 'ยูเรีย (Urea)' → ใส่ %N=46 → บันทึก\n- ตัวอย่าง: RM-001 ยูเรีย 46-0-0", tips: "ประเภทเลือก ธาตุอาหาร ไว้ก่อน ถ้าเป็น FILLER ค่อยเปลี่ยน" },
        { title: "11. สินค้าสำเร็จรูป (FG)", icon: "fa-solid fa-box", image: "products.png", body: "ฟิลด์: รหัสสินค้า* (FG-*** รันต่อ readonly), รหัสเก่า, ชื่อสินค้า*, ประเภทสินค้า (BB/HP/CP ดีฟอลต์ BB), แบรนด์, ขนาดบรรจุ (50kg/1,000kg/1,200kg ดีฟอลต์ 50kg), สูตรที่ใช้ (dropdown ว่าง '-- ดึงมาจากสูตรการผลิต --' รอ BOM ในอนาคต), หมายเหตุ\n- เพิ่ม: รหัส FG-006 ขึ้นรอ + 2 dropdown ดีฟอลต์ → ใส่ชื่อ → เลือกสูตร (ยังว่าง) → บันทึก", tips: "สูตรที่ใช้ ยังว่างไว้ก่อน อนาคตจะดึงจาก BOM Headers" },
        { title: "12. บรรจุภัณฑ์ (Packaging)", icon: "fa-solid fa-boxes-stacked", image: "packaging.png", body: "ฟิลด์: รหัสกระสอบ* (PKG-*** รันต่อ readonly), รหัสเก่า, ชื่อกระสอบ*, ขนาด (50kg/1,000kg/1,200kg ดีฟอลต์ 50kg ขึ้นรอ), หน่วยนับ (ใบ ค่าจริง readonly เทา), ผู้ขาย (dropdown ดึงจาก vendors 'VEND-001 : ชื่อ' มีค่าว่าง '-- เลือกจาก Vendor --' รอในช่อง), รหัส FG (ดึงจาก products มีค่าว่าง '-- เลือกจาก FG List --'), ราคาทุน (placeholder 0), หมายเหตุ\n- เพิ่ม: รหัส PKG-004 ขึ้นรอ + ขนาด/ใบรอ → เลือกผู้ขาย/FG → บันทึก\n- ตารางโชว์: ผู้ขาย / FG / หน่วยนับ", tips: "ผู้ขาย/FG ปล่อยว่างได้ถ้ายังไม่ผูก - จะโชว์ค่าว่างรอเลือกในช่อง" },
        { title: "13. จัดการพนักงาน (สิทธิ์)", icon: "fa-solid fa-user-shield", image: "employees.png", body: "ฟิลด์: Username* / Password* / ชื่อ-นามสกุล* / สิทธิ์ (admin/manager/operator/viewer) / สถานะ (ใช้งาน/ระงับ)\n- role ใช้กำหนดสิทธิ์เมนูในอนาคต (admin เห็นหมด)\n- สถานะ ระงับ = ล็อกอินไม่ได้ → Toast แดง\n- ใช้ login เดียวกับตาราง Supabase employees", tips: "ทดสอบด้วย admin/123456 ก่อน แล้วค่อยสร้าง user อื่น" },
        { title: "14. รายงาน & การแจ้งเตือนสี", icon: "fa-solid fa-file-excel", body: "เมนู 'รายงานทั้งหมด' โชว์การ์ด 9 ตาราง + จำนวนรายการ + ปุ่ม 'ดูข้อมูล' ไปแต่ละหน้า\n- การลบ → Modal สีแดง (bg-red-50, fa-trash, ปุ่มแดง) ไม่ใช่กล่องขาว\n- สำเร็จ → Toast เขียวกลางบน (top-6 left-1/2) 2.5วิ 'บันทึกสำเร็จ' / 'ลบสำเร็จ'\n- ผิดพลาด → Toast แดง 'เกิดข้อผิดพลาด: ...'\n- ออกจากระบบ / รีเซ็ต Supabase → Modal สีส้ม/น้ำเงิน", tips: "Toast อยู่กลางบนเด่น ไม่ต้องก้มมองมุมล่างขวา" },
        { title: "15. เคล็ดลับใช้งานทั่วไป", icon: "fa-solid fa-lightbulb", body: "- รหัสที่รันต่อใช้ $set ให้ขึ้นรอทันที ไม่ต้องคลิกฟิลด์ก่อน\n- ช่องตัวเลข placeholder 0 จะว่างให้เห็น 0 จางๆ พิมพ์ทับได้เลย ไม่เป็น 02 (ใช้ :value + @input + @blur)\n- ช่องจำนวนโซน ลบ 1 ได้, พิมพ์ว่างได้ตอนพิมพ์ (updateZones อนุญาตว่าง)\n- กด 'พิมพ์' ในหน้าคู่มือนี้จะ Print → Save as PDF ได้ทันที (Word ให้เปิด HTML แล้ว Save as DOCX)\n- รองรับ Mobile / Tablet / Desktop, เมนูมี backdrop ดำ, Toast กลางบนเด่น", tips: "ใช้บนมือถือได้ - เมนูมีปุ่ม ☰" },
      ],
    };
  },
  computed: {
    currentTabObj() {
      return this.tabs.find((t) => t.id === this.currentTab) || this.tabs[0];
    },
    currentTitle() {
      if (this.currentTab === "dashboard") return "แดชบอร์ด & ภาพรวม";
      if (this.currentTab === "reports") return "รายงานข้อมูลทั้งหมด";
      if (this.currentTab === "help") return "คู่มือการใช้งาน";
      return this.currentTabObj.name;
    },
    filteredHelp() {
      if (!this.helpSearch) return this.helpSections;
      const q = this.helpSearch.toLowerCase();
      return this.helpSections.filter((s) => (s.title + s.body + (s.tips || "")).toLowerCase().includes(q));
    },
    filteredItems() {
      if (!this.searchQuery) return this.items;
      const q = this.searchQuery.toLowerCase();
      return this.items.filter((item) => {
        return Object.values(item).some((val) => String(val).toLowerCase().includes(q));
      });
    },
    getWarehouseUnitLabel() {
      if (this.warehouseForm.type === "โกดังบรรจุภัณฑ์PKG") return "ใบ";
      return "ตัน";
    },
  },
  watch: {
    currentTab(newTab) {
      this.searchQuery = "";
      if (!["dashboard", "reports"].includes(newTab)) {
        this.fetchData();
        if (newTab === "warehouses") {
          this.updateNextWarehouseCode();
        }
      } else {
        this.fetchAllData();
      }
    },
    isLoggedIn(val) {
      if (val) {
        this.fetchAllData();
      }
    },
  },
  mounted() {
    if (this.isConfigured && this.isLoggedIn) {
      this.fetchAllData();
      this.fetchData();
    }
    // ซ่อน badge Netlify Drop ชั่วคราว (วิธี1) - ลบ div ที่มีข้อความ Build your own site
    setTimeout(() => {
      document.querySelectorAll("div, a").forEach((el) => {
        if (el.textContent && el.textContent.includes("Build your own site with Netlify")) {
          const box = el.closest("div.fixed") || el.closest("div") || el;
          if (box) box.style.display = "none";
        }
        if (el.textContent && el.textContent.includes("Powered by Netlify")) {
          el.style.display = "none";
        }
      });
    }, 800);
  },
  methods: {
    formatCellValue(val, key) {
      if (val === undefined || val === null) return "-";
      if (key === "created_at" && typeof val === "string" && val.includes("T")) {
        const d = new Date(val);
        if (!isNaN(d.getTime())) {
          const year = d.getFullYear();
          const month = String(d.getMonth() + 1).padStart(2, "0");
          const day = String(d.getDate()).padStart(2, "0");
          const hours = String(d.getHours()).padStart(2, "0");
          const minutes = String(d.getMinutes()).padStart(2, "0");
          const seconds = String(d.getSeconds()).padStart(2, "0");
          return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
        }
      }
      return val;
    },
    getFormattedUnitText(val) {
      const num = Number(val) || 0;
      if (this.warehouseForm.type === "โกดังบรรจุภัณฑ์PKG") {
        // return `${num} ใบ`
        return `ใบ`;
      } else {
        const bags = num * 20;
        return ` ตัน (${bags.toLocaleString()} กระสอบ 50 กก.)`;
        // return `${num} ตัน (${bags.toLocaleString()} กระสอบ 50 กก.)`
      }
    },
    updateZones() {
      // allow empty while typing (so user can delete "1" to type "10")
      const raw = this.warehouseForm.zoneCount;
      if (raw === "" || raw === null || raw === undefined) {
        return;
      }
      const num = Number(raw);
      if (isNaN(num) || num === 0) return;
      const count = Math.max(1, Math.min(10, num));
      // only update if valid, keep raw string as number for display
      const newZones = [];
      for (let i = 1; i <= count; i++) {
        const zoneName = "Z" + String(i).padStart(2, "0");
        const existing = this.warehouseForm.zones.find((z) => z.name === zoneName);
        newZones.push({ name: zoneName, capacity: existing ? existing.capacity : 0 });
      }
      this.warehouseForm.zones = newZones;
    },
    ensureZoneCount() {
      const raw = this.warehouseForm.zoneCount;
      if (raw === "" || raw === null || raw === undefined || isNaN(Number(raw))) {
        this.warehouseForm.zoneCount = 1;
        this.updateZones();
        return;
      }
      const count = Math.max(1, Math.min(10, Number(raw)));
      this.warehouseForm.zoneCount = count;
      this.updateZones();
    },
    async updateNextWarehouseCode() {
      if (!this.supabaseClient) return;
      let prefix = "WH-RAW-";
      if (this.warehouseForm.type === "โกดังสินค้าFG") prefix = "WH-FG-";
      if (this.warehouseForm.type === "โกดังบรรจุภัณฑ์PKG") prefix = "WH-PKG-";

      try {
        const { data, error } = await this.supabaseClient
          .from("warehouses")
          .select("main_code")
          .like("main_code", prefix + "%")
          .order("id", { ascending: false })
          .limit(1);

        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].main_code;
          const parts = lastCode.split("-");
          const num = parseInt(parts[parts.length - 1], 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        this.warehouseForm.mainCode = prefix + String(nextNum).padStart(3, "0");
      } catch (err) {
        console.error("Error getting next warehouse code:", err);
        this.warehouseForm.mainCode = prefix + "001";
      }
    },
    onWarehouseTypeChange() {
      this.updateNextWarehouseCode();
    },
    async updateNextVendorCode() {
      if (!this.supabaseClient) return;
      const prefix = "VEND-";
      try {
        const { data, error } = await this.supabaseClient
          .from("vendors")
          .select("vendor_code")
          .like("vendor_code", prefix + "%")
          .order("vendor_code", { ascending: false })
          .limit(1);
        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].vendor_code;
          const num = parseInt(lastCode.replace(prefix, ""), 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        // auto fill only vendor_code - use $set ให้ reactive ขึ้นรอเหมือนกระสอบ
        this.$set(this.formData, "vendor_code", prefix + String(nextNum).padStart(3, "0"));
      } catch (err) {
        console.error("Error getting next vendor code:", err);
        this.$set(this.formData, "vendor_code", prefix + "001");
      }
    },
    async updateNextCustomerCode() {
      if (!this.supabaseClient) return;
      const prefix = "CUST-";
      try {
        const { data, error } = await this.supabaseClient
          .from("customers")
          .select("customer_code")
          .like("customer_code", prefix + "%")
          .order("customer_code", { ascending: false })
          .limit(1);
        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].customer_code;
          const num = parseInt(lastCode.replace(prefix, ""), 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        this.$set(this.formData, "customer_code", prefix + String(nextNum).padStart(3, "0"));
      } catch (err) {
        console.error("Error getting next customer code:", err);
        this.$set(this.formData, "customer_code", prefix + "001");
      }
    },
    async updateNextRawMaterialCode() {
      if (!this.supabaseClient) return;
      const prefix = "RM-";
      try {
        const { data, error } = await this.supabaseClient
          .from("raw_materials")
          .select("rm_code")
          .like("rm_code", prefix + "%")
          .order("rm_code", { ascending: false })
          .limit(1);
        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].rm_code;
          const num = parseInt(lastCode.replace(prefix, ""), 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        this.$set(this.formData, "rm_code", prefix + String(nextNum).padStart(3, "0"));
        // set default type if empty - แนะนำดีฟอลต์ "ธาตุอาหาร"
        if (!this.formData.rm_type) this.$set(this.formData, "rm_type", "ธาตุอาหาร");
      } catch (err) {
        console.error("Error getting next RM code:", err);
        this.$set(this.formData, "rm_code", prefix + "001");
        if (!this.formData.rm_type) this.$set(this.formData, "rm_type", "ธาตุอาหาร");
      }
    },
    async updateNextProductCode() {
      if (!this.supabaseClient) return;
      const prefix = "FG-";
      try {
        const { data, error } = await this.supabaseClient
          .from("products")
          .select("product_code")
          .like("product_code", prefix + "%")
          .order("product_code", { ascending: false })
          .limit(1);
        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].product_code;
          const num = parseInt(lastCode.replace(prefix, ""), 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        this.$set(this.formData, "product_code", prefix + String(nextNum).padStart(3, "0"));
      } catch (err) {
        console.error("Error getting next FG code:", err);
        this.$set(this.formData, "product_code", prefix + "001");
      }
    },
    async updateNextPackagingCode() {
      if (!this.supabaseClient) return;
      const prefix = "PKG-";
      try {
        const { data, error } = await this.supabaseClient
          .from("packaging")
          .select("pkg_code")
          .like("pkg_code", prefix + "%")
          .order("pkg_code", { ascending: false })
          .limit(1);
        let nextNum = 1;
        if (!error && data && data.length > 0) {
          const lastCode = data[0].pkg_code;
          const num = parseInt(lastCode.replace(prefix, ""), 10);
          if (!isNaN(num)) nextNum = num + 1;
        }
        this.$set(this.formData, "pkg_code", prefix + String(nextNum).padStart(3, "0"));
      } catch (err) {
        console.error("Error getting next PKG code:", err);
        this.$set(this.formData, "pkg_code", prefix + "001");
      }
    },
    async fetchPackagingOptions() {
      if (!this.supabaseClient) return;
      try {
        // vendors for dropdown
        const { data: vData } = await this.supabaseClient
          .from("vendors")
          .select("vendor_code, vendor_name")
          .order("vendor_code", { ascending: true });
        const vOpts = vData?.map((v) => `${v.vendor_code} : ${v.vendor_name}`) || [];
        // products for FG dropdown
        const { data: pData } = await this.supabaseClient
          .from("products")
          .select("product_code, product_name")
          .order("product_code", { ascending: true });
        const pOpts = pData?.map((p) => `${p.product_code} : ${p.product_name}`) || [];
        const pkgTab = this.tabs.find((t) => t.id === "packaging");
        if (pkgTab) {
          const vField = pkgTab.fields.find((f) => f.key === "vendor");
          if (vField) vField.options = vOpts.length ? vOpts : ["-- ไม่มีข้อมูลเจ้าหนี้ --"];
          const fgField = pkgTab.fields.find((f) => f.key === "fg_code");
          if (fgField) fgField.options = pOpts.length ? pOpts : ["-- ไม่มีข้อมูล FG --"];
        }
        this.vendorOptions = vOpts;
        this.productOptions = pOpts;
      } catch (err) {
        console.error("Error fetching packaging options:", err);
      }
    },
    async saveWarehouses() {
      if (!this.supabaseClient) return;
      this.warehouseSaving = true;
      try {
        const now = new Date().toISOString();
        const rowsToInsert = this.warehouseForm.zones.map((zone, idx) => {
          const cap =
            zone.capacity === "" || zone.capacity === null
              ? 0
              : Number(zone.capacity) || 0;
          const unitText = this.getFormattedUnitText(cap);
          return {
            code_id:
              "ID-" + Math.floor(Math.random() * 900000 + 100000) + "-" + (idx + 1),
            warehouse_type: this.warehouseForm.type,
            main_code: this.warehouseForm.mainCode,
            sub_zone: zone.name,
            capacity: cap,
            unit: unitText,
            created_at: now,
          };
        });

        const { error } = await this.supabaseClient
          .from("warehouses")
          .insert(rowsToInsert);
        if (error) throw error;

        this.closeModal();
        this.fetchData();
        this.fetchAllData();
        this.updateNextWarehouseCode();
        this.showToast("บันทึกโกดังสำเร็จ", "success");
      } catch (err) {
        this.showToast("เกิดข้อผิดพลาด: " + err.message, "error");
      } finally {
        this.warehouseSaving = false;
      }
    },
    saveConfig() {
      if (!this.tempUrl || !this.tempKey) {
        this.showToast("กรุณากรอก URL และ Key ให้ครบถ้วน", "error");
        return;
      }
      localStorage.setItem("sb_url", this.tempUrl.trim());
      localStorage.setItem("sb_key", this.tempKey.trim());
      this.supabaseClient = createClient(this.tempUrl.trim(), this.tempKey.trim());
      this.isConfigured = true;
    },
    async handleLogin() {
      this.loginLoading = true;
      try {
        const u = this.loginForm.username.trim();
        const p = this.loginForm.password.trim();
        // ใช้ ilike ให้พิมพ์เล็ก/ใหญ่ก็ได้ (case-insensitive)
        const { data, error } = await this.supabaseClient
          .from("employees")
          .select("*")
          .ilike("username", u)
          .single();

        if (error || !data) {
          this.showToast("ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง", "error");
          return;
        }
        // เทียบรหัสผ่านแบบไม่สนเล็กใหญ่ด้วย (อยากให้เคสเข้มงวดให้ลบ .toLowerCase() ออก)
        if (String(data.password).toLowerCase() !== String(p).toLowerCase()) {
          this.showToast("ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง", "error");
          return;
        }

        if (data.status === "ระงับ") {
          this.showToast("บัญชีนี้ถูกระงับการใช้งาน", "error");
          return;
        }

        this.currentUser = data;
        this.isLoggedIn = true;
        localStorage.setItem("current_user", JSON.stringify(data));
        this.fetchAllData();
      } catch (err) {
        this.showToast("เกิดข้อผิดพลาดในการเข้าสู่ระบบ: " + err.message, "error");
      } finally {
        this.loginLoading = false;
      }
    },
    handleLogout() {
      this.showConfirm(
        "ออกจากระบบ",
        "คุณต้องการออกจากระบบใช่หรือไม่?",
        "logout",
        () => {
          localStorage.removeItem("current_user");
          this.isLoggedIn = false;
          this.currentUser = {};
          this.showToast("ออกจากระบบแล้ว", "info");
        }
      );
    },
    resetConfig() {
      this.showConfirm(
        "เปลี่ยนการตั้งค่า",
        "คุณต้องการเปลี่ยนการตั้งค่า Supabase ใช่หรือไม่?",
        "info",
        () => {
          localStorage.removeItem("sb_url");
          localStorage.removeItem("sb_key");
          this.isConfigured = false;
          this.showToast("รีเซ็ตการตั้งค่าแล้ว", "info");
        }
      );
    },
    showConfirm(title, message, type, action) {
      this.confirmTitle = title;
      this.confirmMessage = message;
      this.confirmType = type;
      this.confirmAction = action;
      this.confirmVisible = true;
    },
    handleConfirm() {
      const action = this.confirmAction;
      this.confirmVisible = false;
      if (action) action();
    },
    showToast(message, type = "success") {
      this.toastMessage = message;
      this.toastType = type;
      this.toastVisible = true;
      setTimeout(() => (this.toastVisible = false), 2500);
    },
    isRequired(key) {
      const map = {
        companies: ["thai_name"],
        crop_years: ["year_code", "start_date", "end_date"],
        vendors: ["vendor_code", "vendor_name"],
        customers: ["customer_code", "customer_name"],
        raw_materials: ["rm_code", "rm_name"],
        products: ["product_code", "product_name"],
        packaging: ["pkg_code", "pkg_name"],
        employees: ["username", "password", "full_name"],
        warehouses: ["warehouse_type", "main_code"],
      };
      const req = map[this.currentTab] || [];
      return req.includes(key);
    },
    async fetchData() {
      if (!this.supabaseClient || ["dashboard", "reports"].includes(this.currentTab))
        return;
      this.loading = true;
      try {
        const tableName =
          this.currentTab === "warehouses" ? "warehouses" : this.currentTabObj.table;
        const { data, error } = await this.supabaseClient
          .from(tableName)
          .select("*")
          .order("id", { ascending: false });
        if (error) throw error;
        this.items = data || [];
      } catch (err) {
        console.error("Error fetching data:", err.message);
      } finally {
        this.loading = false;
      }
    },
    async fetchAllData() {
      if (!this.supabaseClient || !this.isLoggedIn) return;
      for (const tab of this.tabs) {
        try {
          const { count, error } = await this.supabaseClient
            .from(tab.table)
            .select("*", { count: "exact", head: true });
          if (!error) this.counts[tab.id] = count || 0;
        } catch (err) {
          console.error(`Error counting ${tab.id}:`, err);
        }
      }
    },
    openModal(item = null) {
      this.formData = {};
      if (item) {
        this.isEditing = true;
        this.editingId = item.id;
        this.formData = { ...item };
        if (this.currentTab === "packaging") {
          this.fetchPackagingOptions();
        }
      } else {
        this.isEditing = false;
        this.editingId = null;
        if (this.currentTab === "companies") {
          if (!this.formData.branch) this.$set(this.formData, "branch", "สำนักงานใหญ่");
        } else if (this.currentTab === "crop_years") {
          if (!this.formData.status) this.$set(this.formData, "status", "เปิด");
        } else if (this.currentTab === "warehouses") {
          // reset to default 1 zone every time open create modal
          this.warehouseForm.zoneCount = 1;
          this.warehouseForm.zones = [{ name: "Z01", capacity: 0 }];
          this.updateNextWarehouseCode();
        } else if (this.currentTab === "vendors") {
          this.updateNextVendorCode();
          // ประเภทเจ้าหนี้ ดีฟอลต์ "1" ขึ้นรอในช่อง
          if (!this.formData.vendor_type) this.$set(this.formData, "vendor_type", "1");
        } else if (this.currentTab === "customers") {
          this.updateNextCustomerCode();
          // ประเภท/สถานะเครดิต/เกรด ดีฟอลต์ขึ้นรอ
          if (!this.formData.customer_type) this.$set(this.formData, "customer_type", "1");
          if (!this.formData.credit_status) this.$set(this.formData, "credit_status", "ปกติ");
          if (!this.formData.customer_grade) this.$set(this.formData, "customer_grade", "A");
        } else if (this.currentTab === "raw_materials") {
          this.updateNextRawMaterialCode();
        } else if (this.currentTab === "products") {
          this.updateNextProductCode();
          // ประเภทสินค้า/ขนาดบรรจุ ดีฟอลต์ขึ้นรอ, สูตรที่ใช้ รอเลือก (ค่าว่าง placeholder)
          if (!this.formData.product_type) this.$set(this.formData, "product_type", "BB");
          if (!this.formData.pack_size) this.$set(this.formData, "pack_size", "50 kg");
          if (this.formData.formula === undefined) this.$set(this.formData, "formula", "");
        } else if (this.currentTab === "packaging") {
          // set unit default "ใบ" ค่าจริง, vendor/fg_code รอเลือก (โชว์ -- เลือกจาก Vendor -- ในช่อง), ขนาดดีฟอลต์ 50 kg ขึ้นรอ, fetch dropdowns, and auto pkg_code
          this.$set(this.formData, "unit", "ใบ");
          this.$set(this.formData, "vendor", "");
          this.$set(this.formData, "fg_code", "");
          if (!this.formData.pack_size) this.$set(this.formData, "pack_size", "50 kg");
          this.fetchPackagingOptions();
          this.updateNextPackagingCode();
        }
      }
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.warehouseSaving = false;
    },
    async saveItem() {
      // validate required ก่อนบันทึก - โฟกัสช่องแรกที่ว่าง
      for (const field of this.currentTabObj.fields || []) {
        if (this.isRequired(field.key)) {
          const val = this.formData[field.key];
          if (val === undefined || val === null || String(val).trim() === "") {
            this.showToast(`กรุณากรอก ${field.label}`, "error");
            // focus ช่องแรกที่ว่าง
            this.$nextTick(() => {
              const el = document.querySelector(`[placeholder="${field.placeholder || ""}"]`);
              if (el) el.focus();
            });
            return;
          }
        }
      }
      try {
        this.formData.created_at = new Date().toISOString();

        if (this.isEditing) {
          const { error } = await this.supabaseClient
            .from(this.currentTabObj.table)
            .update(this.formData)
            .eq("id", this.editingId);
          if (error) throw error;
        } else {
          delete this.formData.id;
          const { error } = await this.supabaseClient
            .from(this.currentTabObj.table)
            .insert([this.formData]);
          if (error) throw error;
        }
        this.closeModal();
        this.fetchData();
        this.fetchAllData();
        this.showToast("บันทึกข้อมูลสำเร็จ", "success");
      } catch (err) {
        this.showToast("เกิดข้อผิดพลาด: " + err.message, "error");
      }
    },
    async deleteItem(id) {
      this.showConfirm(
        "ยืนยันการลบ",
        "คุณต้องการลบข้อมูลนี้ใช่หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้",
        "delete",
        async () => {
          try {
            const tableName =
              this.currentTab === "warehouses" ? "warehouses" : this.currentTabObj.table;
            const { error } = await this.supabaseClient.from(tableName).delete().eq("id", id);
            if (error) throw error;
            this.fetchData();
            this.fetchAllData();
            this.showToast("ลบข้อมูลสำเร็จ", "success");
          } catch (err) {
            this.showToast("เกิดข้อผิดพลาด: " + err.message, "error");
          }
        }
      );
    },
    exportCurrentTab() {
      if (["dashboard", "reports"].includes(this.currentTab)) {
        this.showToast("หน้านี้ไม่มีข้อมูลให้ส่งออก", "info");
        return;
      }
      const data = this.filteredItems.length ? this.filteredItems : this.items;
      if (!data || data.length === 0) {
        this.showToast("ไม่มีข้อมูลให้ส่งออก", "info");
        return;
      }
      const cols = this.currentTabObj.columns;
      const header = cols.map((c) => `"${c.label.replace(/"/g, '""')}"`).join(",");
      const rows = data.map((item) =>
        cols
          .map((c) => {
            const v = this.formatCellValue(item[c.key], c.key);
            const str = v === null || v === undefined ? "" : String(v);
            return `"${str.replace(/"/g, '""')}"`;
          })
          .join(",")
      );
      const csv = "\uFEFF" + [header, ...rows].join("\n");
      const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      const date = new Date().toISOString().slice(0, 10);
      a.href = url;
      a.download = `${this.currentTab}-${date}.csv`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      this.showToast(`ส่งออก ${data.length} รายการสำเร็จ`, "success");
    },
  },
};
</script>
