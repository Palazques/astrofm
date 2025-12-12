import React, { useState } from 'react';

const Profile = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [dailyAlignReminder, setDailyAlignReminder] = useState(true);
  const [shareActivity, setShareActivity] = useState(false);

  const user = {
    name: "Paul",
    username: "@cosmicpaul",
    avatar: { color1: "#FF59D0", color2: "#7D67FE", color3: "#00D4AA" },
    birthData: {
      date: "July 15, 1990",
      time: "3:42 PM",
      location: "Los Angeles, CA",
    },
    sign: "Cancer",
    rising: "Libra",
    moon: "Scorpio",
    dominantFrequency: "528 Hz",
    element: "Water",
    joinedDate: "November 2024",
  };

  const stats = [
    { label: "Total Alignments", value: "247", icon: "⟳" },
    { label: "Streak", value: "12 days", icon: "🔥" },
    { label: "Connections", value: "23", icon: "✦" },
    { label: "Saved Moments", value: "89", icon: "💾" },
  ];

  const recentAchievements = [
    { id: 1, name: "Early Riser", description: "Aligned before 7 AM", icon: "🌅", color: "#FAFF0E" },
    { id: 2, name: "Social Butterfly", description: "Aligned with 10 friends", icon: "🦋", color: "#FF59D0" },
    { id: 3, name: "Full Moon Master", description: "Aligned during 5 full moons", icon: "🌕", color: "#7D67FE" },
  ];

  const menuItems = [
    { id: 'edit-birth', label: 'Edit Birth Data', icon: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z' },
    { id: 'sound-settings', label: 'Sound Preferences', icon: 'M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z' },
    { id: 'connected-apps', label: 'Connected Apps', icon: 'M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1' },
    { id: 'privacy', label: 'Privacy & Security', icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z' },
    { id: 'help', label: 'Help & Support', icon: 'M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z' },
  ];

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(180deg, #0A0A0F 0%, #0D0D15 50%, #12101A 100%)',
      fontFamily: "'Syne', sans-serif",
      color: '#FFFFFF',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Space+Grotesk:wght@300;400;500&display=swap');
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-8px); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.05); }
        }
        
        @keyframes rotateRing {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes shimmer {
          0% { background-position: -200% center; }
          100% { background-position: 200% center; }
        }
        
        .glass-card {
          background: rgba(255, 255, 255, 0.03);
          backdrop-filter: blur(20px);
          -webkit-backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 24px;
        }
        
        .profile-orb {
          position: relative;
          width: 120px;
          height: 120px;
          border-radius: 50%;
          animation: float 6s ease-in-out infinite;
        }
        
        .profile-orb::before {
          content: '';
          position: absolute;
          inset: -15px;
          border-radius: 50%;
          background: inherit;
          filter: blur(25px);
          opacity: 0.5;
        }
        
        .orb-ring {
          position: absolute;
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 50%;
          animation: rotateRing 20s linear infinite;
        }
        
        .menu-item {
          transition: all 0.2s ease;
        }
        
        .menu-item:hover {
          background: rgba(255, 255, 255, 0.06);
          transform: translateX(4px);
        }
        
        .toggle-switch {
          position: relative;
          width: 48px;
          height: 28px;
          background: rgba(255, 255, 255, 0.1);
          border-radius: 14px;
          cursor: pointer;
          transition: all 0.3s ease;
        }
        
        .toggle-switch.active {
          background: linear-gradient(135deg, #7D67FE 0%, #FF59D0 100%);
        }
        
        .toggle-switch::after {
          content: '';
          position: absolute;
          top: 3px;
          left: 3px;
          width: 22px;
          height: 22px;
          background: white;
          border-radius: 50%;
          transition: all 0.3s ease;
        }
        
        .toggle-switch.active::after {
          transform: translateX(20px);
        }
        
        .stat-card {
          transition: all 0.2s ease;
        }
        
        .stat-card:hover {
          transform: translateY(-4px);
          background: rgba(255, 255, 255, 0.06);
        }
        
        .achievement-badge {
          transition: all 0.2s ease;
        }
        
        .achievement-badge:hover {
          transform: scale(1.05);
        }
        
        .nav-item {
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .nav-item:hover {
          transform: translateY(-2px);
        }
      `}</style>

      {/* Background Elements */}
      <div style={{
        position: 'absolute',
        top: '0%',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '600px',
        height: '600px',
        background: 'radial-gradient(circle, rgba(255, 89, 208, 0.1) 0%, rgba(125, 103, 254, 0.05) 40%, transparent 70%)',
        borderRadius: '50%',
        filter: 'blur(80px)',
        animation: 'pulse 10s ease-in-out infinite',
      }} />

      {/* Main Container */}
      <div style={{
        maxWidth: '420px',
        margin: '0 auto',
        padding: '20px',
        position: 'relative',
        zIndex: 10,
      }}>
        
        {/* Status Bar */}
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '12px 8px',
          fontSize: '14px',
          fontFamily: "'Space Grotesk', sans-serif",
          fontWeight: 500,
        }}>
          <span>9:41</span>
          <div style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
            <svg width="18" height="12" viewBox="0 0 18 12" fill="white"><path d="M1 4C1 3.45 1.45 3 2 3H3C3.55 3 4 3.45 4 4V11C4 11.55 3.55 12 3 12H2C1.45 12 1 11.55 1 11V4Z" fillOpacity="0.4"/><path d="M5 3C5 2.45 5.45 2 6 2H7C7.55 2 8 2.45 8 3V11C8 11.55 7.55 12 7 12H6C5.45 12 5 11.55 5 11V3Z" fillOpacity="0.6"/><path d="M9 1C9 0.45 9.45 0 10 0H11C11.55 0 12 0.45 12 1V11C12 11.55 11.55 12 11 12H10C9.45 12 9 11.55 9 11V1Z"/><path d="M13 2C13 1.45 13.45 1 14 1H15C15.55 1 16 1.45 16 2V11C16 11.55 15.55 12 15 12H14C13.45 12 13 11.55 13 11V2Z"/></svg>
            <div style={{ width: '28px', height: '13px', border: '1.5px solid white', borderRadius: '4px', padding: '2px' }}>
              <div style={{ width: '80%', height: '100%', background: '#FAFF0E', borderRadius: '2px' }} />
            </div>
          </div>
        </div>

        {/* Header */}
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          padding: '16px 0 24px',
        }}>
          <button style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: 'none',
            borderRadius: '12px',
            padding: '10px',
            cursor: 'pointer',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
          </button>
          
          <h1 style={{ fontSize: '20px', fontWeight: 700, margin: 0 }}>Profile</h1>
          
          <button style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: 'none',
            borderRadius: '12px',
            padding: '10px',
            cursor: 'pointer',
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
          </button>
        </div>

        {/* Profile Header Card */}
        <div className="glass-card" style={{
          padding: '28px',
          marginBottom: '20px',
          textAlign: 'center',
          position: 'relative',
          overflow: 'hidden',
        }}>
          {/* Background gradient */}
          <div style={{
            position: 'absolute',
            top: '-50%',
            left: '50%',
            transform: 'translateX(-50%)',
            width: '300px',
            height: '300px',
            background: 'radial-gradient(circle, rgba(255, 89, 208, 0.15) 0%, transparent 60%)',
            borderRadius: '50%',
            filter: 'blur(40px)',
          }} />

          <div style={{ position: 'relative', zIndex: 1 }}>
            {/* Profile Orb */}
            <div 
              className="profile-orb"
              style={{
                background: `linear-gradient(135deg, ${user.avatar.color1} 0%, ${user.avatar.color2} 50%, ${user.avatar.color3} 100%)`,
                margin: '0 auto 20px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <div className="orb-ring" style={{ inset: '-20px' }} />
              <div className="orb-ring" style={{ inset: '-35px', animationDuration: '30s', animationDirection: 'reverse' }} />
              <span style={{ fontSize: '42px', fontWeight: 800, position: 'relative', zIndex: 1 }}>
                {user.name[0]}
              </span>
            </div>

            {/* Name & Username */}
            <h2 style={{
              fontSize: '26px',
              fontWeight: 800,
              margin: '0 0 4px 0',
              background: 'linear-gradient(135deg, #FFFFFF 0%, rgba(255,255,255,0.8) 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}>{user.name}</h2>
            <p style={{
              fontSize: '14px',
              color: 'rgba(255,255,255,0.5)',
              margin: '0 0 16px 0',
              fontFamily: "'Space Grotesk', sans-serif",
            }}>{user.username}</p>

            {/* Sign Tags */}
            <div style={{ display: 'flex', justifyContent: 'center', gap: '10px', flexWrap: 'wrap', marginBottom: '16px' }}>
              <div style={{
                background: 'rgba(250, 255, 14, 0.1)',
                border: '1px solid rgba(250, 255, 14, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
              }}>
                <span style={{ fontSize: '14px' }}>☉</span>
                <span style={{ fontSize: '12px', color: '#FAFF0E', fontWeight: 600 }}>{user.sign}</span>
              </div>
              <div style={{
                background: 'rgba(255, 89, 208, 0.1)',
                border: '1px solid rgba(255, 89, 208, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
              }}>
                <span style={{ fontSize: '14px' }}>☽</span>
                <span style={{ fontSize: '12px', color: '#FF59D0', fontWeight: 600 }}>{user.moon}</span>
              </div>
              <div style={{
                background: 'rgba(125, 103, 254, 0.1)',
                border: '1px solid rgba(125, 103, 254, 0.2)',
                borderRadius: '20px',
                padding: '6px 14px',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
              }}>
                <span style={{ fontSize: '14px' }}>↑</span>
                <span style={{ fontSize: '12px', color: '#7D67FE', fontWeight: 600 }}>{user.rising}</span>
              </div>
            </div>

            {/* Birth Info */}
            <p style={{
              fontSize: '12px',
              color: 'rgba(255,255,255,0.4)',
              margin: 0,
              fontFamily: "'Space Grotesk', sans-serif",
            }}>
              {user.birthData.date} • {user.birthData.time} • {user.birthData.location}
            </p>
          </div>
        </div>

        {/* Stats Grid */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: '12px',
          marginBottom: '20px',
        }}>
          {stats.map((stat, index) => (
            <div key={index} className="glass-card stat-card" style={{
              padding: '18px',
              textAlign: 'center',
              cursor: 'pointer',
            }}>
              <span style={{ fontSize: '24px', marginBottom: '8px', display: 'block' }}>{stat.icon}</span>
              <p style={{
                fontSize: '22px',
                fontWeight: 800,
                margin: '0 0 4px 0',
                background: 'linear-gradient(135deg, #FAFF0E 0%, #FF59D0 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}>{stat.value}</p>
              <p style={{
                fontSize: '11px',
                color: 'rgba(255,255,255,0.5)',
                margin: 0,
                textTransform: 'uppercase',
                letterSpacing: '1px',
              }}>{stat.label}</p>
            </div>
          ))}
        </div>

        {/* Achievements */}
        <div style={{ marginBottom: '20px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '12px',
          }}>
            <h3 style={{ fontSize: '16px', fontWeight: 700, margin: 0 }}>Recent Achievements</h3>
            <span style={{ fontSize: '13px', color: '#7D67FE', fontWeight: 600, cursor: 'pointer' }}>View All</span>
          </div>

          <div style={{ display: 'flex', gap: '12px', overflowX: 'auto', paddingBottom: '8px' }}>
            {recentAchievements.map((achievement) => (
              <div key={achievement.id} className="achievement-badge glass-card" style={{
                padding: '16px',
                minWidth: '140px',
                textAlign: 'center',
                cursor: 'pointer',
                borderTop: `3px solid ${achievement.color}`,
              }}>
                <span style={{ fontSize: '32px', display: 'block', marginBottom: '10px' }}>{achievement.icon}</span>
                <p style={{ fontSize: '13px', fontWeight: 600, margin: '0 0 4px 0' }}>{achievement.name}</p>
                <p style={{ fontSize: '10px', color: 'rgba(255,255,255,0.5)', margin: 0, fontFamily: "'Space Grotesk', sans-serif" }}>{achievement.description}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Settings Toggles */}
        <div className="glass-card" style={{ padding: '8px', marginBottom: '20px' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <div style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'rgba(250, 255, 14, 0.1)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FAFF0E" strokeWidth="2">
                  <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"/>
                </svg>
              </div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: 600, margin: 0 }}>Notifications</p>
                <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>Push notifications</p>
              </div>
            </div>
            <div 
              className={`toggle-switch ${notificationsEnabled ? 'active' : ''}`}
              onClick={() => setNotificationsEnabled(!notificationsEnabled)}
            />
          </div>

          <div style={{ height: '1px', background: 'rgba(255,255,255,0.06)', margin: '0 16px' }} />

          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <div style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'rgba(125, 103, 254, 0.1)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#7D67FE" strokeWidth="2">
                  <circle cx="12" cy="12" r="10"/>
                  <path d="M12 6v6l4 2"/>
                </svg>
              </div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: 600, margin: 0 }}>Daily Align Reminder</p>
                <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>9:00 AM every day</p>
              </div>
            </div>
            <div 
              className={`toggle-switch ${dailyAlignReminder ? 'active' : ''}`}
              onClick={() => setDailyAlignReminder(!dailyAlignReminder)}
            />
          </div>

          <div style={{ height: '1px', background: 'rgba(255,255,255,0.06)', margin: '0 16px' }} />

          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <div style={{
                width: '40px',
                height: '40px',
                borderRadius: '12px',
                background: 'rgba(255, 89, 208, 0.1)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FF59D0" strokeWidth="2">
                  <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
                  <circle cx="9" cy="7" r="4"/>
                  <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
                </svg>
              </div>
              <div>
                <p style={{ fontSize: '14px', fontWeight: 600, margin: 0 }}>Share Activity</p>
                <p style={{ fontSize: '11px', color: 'rgba(255,255,255,0.5)', margin: 0 }}>Let friends see your alignments</p>
              </div>
            </div>
            <div 
              className={`toggle-switch ${shareActivity ? 'active' : ''}`}
              onClick={() => setShareActivity(!shareActivity)}
            />
          </div>
        </div>

        {/* Menu Items */}
        <div className="glass-card" style={{ padding: '8px', marginBottom: '20px' }}>
          {menuItems.map((item, index) => (
            <React.Fragment key={item.id}>
              <div className="menu-item" style={{
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
                padding: '16px',
                borderRadius: '14px',
                cursor: 'pointer',
              }}>
                <div style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '12px',
                  background: 'rgba(255, 255, 255, 0.05)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d={item.icon} />
                  </svg>
                </div>
                <span style={{ flex: 1, fontSize: '14px', fontWeight: 500 }}>{item.label}</span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2">
                  <path d="M9 18l6-6-6-6"/>
                </svg>
              </div>
              {index < menuItems.length - 1 && (
                <div style={{ height: '1px', background: 'rgba(255,255,255,0.06)', margin: '0 16px' }} />
              )}
            </React.Fragment>
          ))}
        </div>

        {/* Sign Out Button */}
        <button style={{
          width: '100%',
          background: 'rgba(232, 72, 85, 0.1)',
          border: '1px solid rgba(232, 72, 85, 0.2)',
          borderRadius: '16px',
          padding: '16px',
          fontSize: '14px',
          fontWeight: 600,
          fontFamily: "'Syne', sans-serif",
          color: '#E84855',
          cursor: 'pointer',
          marginBottom: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '10px',
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/>
          </svg>
          Sign Out
        </button>

        {/* App Version */}
        <p style={{
          textAlign: 'center',
          fontSize: '11px',
          color: 'rgba(255,255,255,0.3)',
          marginBottom: '120px',
          fontFamily: "'Space Grotesk', sans-serif",
        }}>
          ASTRO.FM v1.0.0 • Member since {user.joinedDate}
        </p>

        {/* Bottom Navigation */}
        <div style={{
          position: 'fixed',
          bottom: 0,
          left: '50%',
          transform: 'translateX(-50%)',
          width: '100%',
          maxWidth: '420px',
          padding: '0 20px 20px',
          boxSizing: 'border-box',
        }}>
          <div className="glass-card" style={{
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'center',
            padding: '14px 8px',
          }}>
            {[
              { id: 'home', icon: 'M3 12L12 3L21 12V21H3V12Z', label: 'Home' },
              { id: 'sound', icon: 'M12 2C13.1 2 14 2.9 14 4V12C14 13.1 13.1 14 12 14C10.9 14 10 13.1 10 12V4C10 2.9 10.9 2 12 2ZM6 10V12C6 15.3 8.7 18 12 18C15.3 18 18 15.3 18 12V10M12 18V22M8 22H16', label: 'Sound' },
              { id: 'align', icon: 'M12 2L2 7L12 12L22 7L12 2ZM2 17L12 22L22 17M2 12L12 17L22 12', label: 'Align' },
              { id: 'calendar', icon: 'M8 7V3M16 7V3M7 11H17M5 21H19C20.1 21 21 20.1 21 19V7C21 5.9 20.1 5 19 5H5C3.9 5 3 5.9 3 7V19C3 20.1 3.9 21 5 21Z', label: 'Calendar' },
              { id: 'profile', icon: 'M20 21V19C20 17.9 19.55 16.88 18.83 16.17C18.1 15.45 17.11 15 16 15H8C6.89 15 5.9 15.45 5.17 16.17C4.45 16.88 4 17.9 4 19V21M12 11C14.21 11 16 9.21 16 7C16 4.79 14.21 3 12 3C9.79 3 8 4.79 8 7C8 9.21 9.79 11 12 11Z', label: 'Profile' },
            ].map((item) => (
              <div 
                key={item.id}
                className="nav-item"
                onClick={() => setActiveTab(item.id)}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  gap: '4px',
                  cursor: 'pointer',
                  padding: '6px 10px',
                }}
              >
                <svg 
                  width="22" 
                  height="22" 
                  viewBox="0 0 24 24" 
                  fill="none"
                  style={{
                    stroke: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.5)',
                    strokeWidth: 2,
                    strokeLinecap: 'round',
                    strokeLinejoin: 'round',
                  }}
                >
                  <path d={item.icon} />
                </svg>
                <span style={{
                  fontSize: '9px',
                  fontWeight: activeTab === item.id ? 600 : 400,
                  color: activeTab === item.id ? '#FAFF0E' : 'rgba(255, 255, 255, 0.5)',
                  textTransform: 'uppercase',
                  letterSpacing: '0.5px',
                }}>{item.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Profile;
