#!/bin/bash
# Script to help download older iOS runtimes

set -e

echo "═══════════════════════════════════════════════════════════════════"
echo "📥 دليل تحميل iOS Runtime أقدم"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "📋 الـ Runtimes المثبتة حالياً:"
echo "───────────────────────────────────────────────────────────────────"
xcrun simctl list runtimes
echo ""

echo "⚠️  المشكلة: iOS 17/18 غير مثبتة"
echo ""
echo "🔧 الحل: تحميل iOS Runtime من Xcode"
echo ""
echo "الخطوات:"
echo "───────────────────────────────────────────────────────────────────"
echo ""
echo "1️⃣  افتح Xcode"
echo "2️⃣  اذهب إلى: Xcode > Settings (أو Preferences) > Components"
echo "3️⃣  في قسم 'Simulators'، ابحث عن:"
echo "    - iOS 17.5 Simulator"
echo "    - iOS 18.0 Simulator"
echo "    - iOS 18.1 Simulator"
echo "4️⃣  اضغط على زر 'Download' بجانب الإصدار المطلوب"
echo "5️⃣  انتظر حتى يكتمل التحميل (قد يستغرق عدة دقائق)"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "💡 بعد التحميل، استخدم هذا الأمر لإنشاء محاكي:"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "# للتحقق من الـ Runtime ID الصحيح بعد التحميل:"
echo "xcrun simctl list runtimes"
echo ""
echo "# ثم أنشئ محاكي (مثال):"
echo "xcrun simctl create \"iPhone 15 Pro iOS 18\" \"iPhone 15 Pro\" \"iOS-18-0\""
echo ""
echo "# أو استخدم الـ Runtime ID الكامل:"
echo "xcrun simctl create \"iPhone 15 Pro iOS 18\" \"iPhone 15 Pro\" \"com.apple.CoreSimulator.SimRuntime.iOS-18-0\""
echo ""
echo "═══════════════════════════════════════════════════════════════════"


